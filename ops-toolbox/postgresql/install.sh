#!/usr/bin/env bash
# Description: PostgreSQL install script
# Author: .Rody
# Date: 2025-01-24 09:36:16

POSTGRESQL_VERSION="16.6"
POSTGRESQL_USER="postgres"
POSTGRESQL_PORT="5432"
POSTGRESQL_PASSWORD="fYvL@Tc&EVFrSMWJ"
POSTGRESQL_DATA_DIR="/data/postgresql/${POSTGRESQL_PORT}"
POSTGRESQL_BASE_DIR="/usr/local/postgresql"
SCRIPT_DIR=$(cd $(dirname $0); pwd)

postgresql_preinstall() {
    # 安装依赖
    dnf install -y gcc-c++ make cmake
    dnf install -y tar wget
    dnf install -y readline-devel zlib-devel openssl-devel libicu-devel

    # 创建用户
    if id $POSTGRESQL_USER &>/dev/null; then
	echo "$POSTGRESQL_USER has been exists."
    else
        echo "$POSTGRESQL_USER is not exists."
	useradd postgres
	if [ $? -eq 0 ];then
            echo "$POSTGRESQL_USER has been created."
	fi
    fi

    # 创建数据目录
    if [ ! -d $POSTGRESQL_DATA_DIR ]; then
        mkdir -p $POSTGRESQL_DATA_DIR/{data,logs}
        chown -R $POSTGRESQL_USER:$POSTGRESQL_USER $POSTGRESQL_DATA_DIR
        chmod -R 750 $POSTGRESQL_DATA_DIR
    else
        echo "PostgreSQL data directory already exists."
        exit 1
    fi
    # 检查安装目录是否存在
    if [ ! -d $POSTGRESQL_BASE_DIR ];then
        echo "PostgreSQL has been installed."
        exit 1
    fi
}

postgresql_install() {
    # 下载源码
    wget https://ftp.postgresql.org/pub/source/v${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.tar.gz

    # 解压源码
    tar -zxvf postgresql-${POSTGRESQL_VERSION}.tar.gz

    # 进入源码目录
    cd postgresql-${POSTGRESQL_VERSION}

    # 编译安装
    ./configure --prefix=$POSTGRESQL_BASE_DIR
    make -j $(nproc)
    make install

    # 设置权限
    chown -R $POSTGRESQL_USER:$POSTGRESQL_USER $POSTGRESQL_BASE_DIR
    # 清理源码
    cd ..
    rm -rf postgresql-${POSTGRESQL_VERSION}
    rm -f postgresql-${POSTGRESQL_VERSION}.tar.gz
}

postgresql_configure() {
    # 初始化数据库
    su - ${POSTGRESQL_USER} -c "$POSTGRESQL_BASE_DIR/bin/initdb -D $POSTGRESQL_DATA_DIR/data"
    
    # 调整配置文件
    cp $SCRIPT_DIR/files/postgresql.conf.sample $POSTGRESQL_DATA_DIR/data/postgresql.conf
    sed -i 's@#POSTGRESQL_PORT#@'${POSTGRESQL_PORT}'@g' $POSTGRESQL_DATA_DIR/data/postgresql.conf
    cp $SCRIPT_DIR/files/pg_hba.conf.sample $POSTGRESQL_DATA_DIR/data/pg_hba.conf
}

postgresql_postinstall() {
    # 设置全局环境变量
    echo "export PATH=$POSTGRESQL_BASE_DIR/bin:\$PATH" >> /etc/profile.d/postgresql.sh
    source /etc/profile

    # 设置systemd服务管理脚本
    mkdir -p /etc/systemd/system/postgresql@.service.d
    echo "[Service]" > /etc/systemd/system/postgresql@.service.d/00-default.conf
    echo 'Environment="PGOPTS=-D /data/postgresql/%i/data -l /data/postgresql/%i/logs/postgresql.log"' >> /etc/systemd/system/postgresql@.service.d/00-default.conf
    cp $SCRIPT_DIR/files/postgresql@.service /etc/systemd/system/postgresql@.service

    # 启动服务
    systemctl daemon-reload
    systemctl start postgresql@5432 
    systemctl status postgresql@5432 
}

postgresql_preinstall
postgresql_install
postgresql_configure
postgresql_postinstall