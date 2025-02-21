#!/usr/bin/env bash
# Description: 执行脚本./install.sh 定义密码，例如：./install.sh 123456
# Author: 
# Date: 2025-01-08 14:16:36

if [ $# -eq 0 ];then
    echo -e "[\033[31mERROR\033[0m] Please pass a parameter as the initial password."
    exit 1
fi
REDIS_PASSWD=$1
SCRIPT_ROOT="$(pwd `dirname $0`)"
REDIS_BASEDIR="/usr/local/redis"
REDIS_DATADIR="/data/redis"
REDIS_START="/etc/systemd/system"
REDIS_VERSION="redis-7.2.1"

redis_check() {
# 定义要检查的包列表
packages=("make" "gcc" "python3")

# 检查并安装每个包
for pkg in "${packages[@]}"; do
    rpm -q "$pkg" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "[\033[32mINFO \033[0m] $pkg is installed."
    else
        echo -e "[\033[33mWARNING\033[0m] $pkg is not installed, attempting to install..."
        yum install -y "$pkg" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "[\033[31mERROR\033[0m] Installation of $pkg failed. Check the network or yum repo source."
            exit 1
        else
            echo -e "[\033[32mINFO \033[0m] $pkg has been successfully installed."
        fi
    fi
done
}

redis_preinstall() {
    # 进程运行用户
    echo -e "[\033[32mINFO \033[0m] Create redis process user."
    [ id redis > /dev/null 2>&1 ] || useradd -r -M -s /bin/false redis

    # 数据目录
    if [ ! -d "${REDIS_DATADIR}" ];then
        echo -e "[\033[32mINFO \033[0m] Create redis data directory."
        mkdir -p ${REDIS_DATADIR}/{logs,data}
        chown -R redis.redis ${REDIS_DATADIR}/ && chmod -R 750 ${REDIS_DATADIR}
    fi
    # 安装目录
    if [ ! -d "${REDIS_BASEDIR}" ];then
        echo -e "[\033[32mINFO \033[0m] Create redis start directory."
        mkdir -p ${REDIS_BASEDIR}
        chown -R redis.redis ${REDIS_BASEDIR}/
    fi
}

redis_config() {
#添加配置文件
cat > ${REDIS_BASEDIR}/redis.conf << EOF
# Redis Server Configuration File
## General
daemonize yes
pidfile /var/run/redis_6379.pid
databases 16

## Network
port 6379
bind *
tcp-backlog 511
timeout 300
tcp-keepalive 300

## Security
protected-mode no
requirepass "${REDIS_PASSWD}"

## Log
loglevel notice
logfile "${REDIS_DATADIR}/logs/6379.log"

## Persistence
### RDB
save 3600 2 300 100 60 10000
dbfilename dump.rdb
dir ${REDIS_DATADIR}/data
### AOF
appendonly yes
appendfilename "appendonly.aof"
appenddirname "appendonlydir"
EOF
#设置服务启动脚本
cat > ${REDIS_START}/redis.service << EOF
Description=Redis Server
After=syslog.target

[Service]
Type=forking
User=redis
Group=redis
ExecStart=${REDIS_BASEDIR}/bin/redis-server ${REDIS_BASEDIR}/redis.conf
RestartSec=5s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

redis_install() {
    if [ -f "${SCRIPT_ROOT}/${REDIS_VERSION}.tar.gz" ];then
        echo -e "[\033[32mINFO \033[0m] Find source file, extracting ..."
        tar zxf ${SCRIPT_ROOT}/${REDIS_VERSION}.tar.gz
        if [ $? -eq 0 ];then
            echo -e "[\033[32mINFO \033[0m] Extract successful."
        else
            echo -e "[\033[31mERROR\033[0m] Extract failed. exit code: $?."
            exit
        fi
        cd ${SCRIPT_ROOT}/${REDIS_VERSION}/deps
        make hdr_histogram hiredis jemalloc linenoise lua fpconv
        if [ $? -ne 0 ];then
            echo -e "[\033[31mERROR\033[0m] Dependency compilation failed."
            exit
        else
            cd ../src
            make -j $(nproc --all) PREFIX=${REDIS_BASEDIR} install
        fi
    else
        echo -e "[\033[31mERROR\033[0m] ${REDIS_VERSION}.tar.gz is not exists. please put on files directory."
        exit 1
    fi
}

redis_startservice() {
    #设置环境变量
    echo "export PATH=${REDIS_BASEDIR}/bin:\$PATH" > /etc/profile.d/redis.sh
    source /etc/profile
    #启动服务
    systemctl daemon-reload
    systemctl enable redis
    systemctl start redis
    if [ $? -eq 0 ];then
        echo -e "[\033[32mINFO \033[0m] Redis service started successfully."
    else
        echo -e "[\033[31mERROR\033[0m] Redis service started failed.Use journalctl -xe | grep redis for details"
        exit 1
    fi
}
redis_check
redis_preinstall
redis_config
redis_install
sleep 10
redis_startservice
