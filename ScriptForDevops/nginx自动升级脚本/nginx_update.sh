#!/bin/bash

# 检查root权限
if [[ $EUID -ne 0 ]]; then
    echo "请使用root权限运行此脚本。"
    exit 1
fi

DATE=$(date +%Y%m%d)

nginx_verion="nginx-1.22.0"
#通过进程获取nginx的exe路径
nginx_pid=`ps -ef |grep nginx | grep -v "grep" | awk '{if ($0~/master/) print $2}'`
nginx_sbin=`cd /proc/${nginx_pid} && ls -l |grep exe |awk '{print $(NF-0)}'`
nginx_conf=`$nginx_sbin -t &> nginx_path && cat nginx_path | awk 'END{print $(NF-3)}'` 
if [ -z $nginx_sbin ]; then
        echo "error,未检测到nginx"
        exit
fi

if [ -z $nginx_conf ]; then
        echo "error,未检测到nginx.conf配置文件"
        exit
fi
#获取编译参数
nginx_configures=`${nginx_sbin} -V &> nginx_temp`
nginx_configure=`cat nginx_temp | grep configure | sed 's/configure arguments: //' `

#备份nginx
cp -a $nginx_sbin ${nginx_sbin}.bak${DATE}

cd /usr/local/src/
#下载nginx
wget http://nginx.org/download/${nginx_verion}.tar.gz

#升级
tar -zxvf ${nginx_verion}.tar.gz
cd $nginx_verion
./configure $nginx_configure


if [ $? -ne 0 ]; then
    echo "编译失败！请排查原因"
    exit
fi

make 

if [ $? -ne 0 ]; then
    echo "安装失败！请排查原因"
    exit
fi
make install

if [ $? -ne 0 ]; then
    echo "安装失败！请排查原因"
    exit
fi

$nginx_sbin -s reload
echo "nginx 升级成功！"
echo "nginx 当前版本为："
$nginx_sbin -V


