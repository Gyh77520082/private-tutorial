#!/bin/bash

docker -v
if [ $? -ne  0 ]; then
	echo "检测到Docker未安装！请先安装docker环境"
	exit 0;  
fi

mkdir -p /home/docker/squid/
cat > /home/docker/squid/squid.conf <<EOF
acl all src 0.0.0.0/0.0.0.0
acl SSL_ports port 443
acl Safe_ports port 80 # http
acl Safe_ports port 443 # https
acl CONNECT method CONNECT
http_access allow all
http_port 3128
visible_hostname proxy
EOF

docker run -d --name squid -p 5001:3128 -v /home/docker/squid/squid.conf:/etc/squid/squid.conf sameersbn/squid

