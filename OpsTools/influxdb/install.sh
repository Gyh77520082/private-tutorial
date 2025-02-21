#!/usr/bin/env bash
# Description: 
# Author: .Rody
# Data: 2024-10-08 16:11:33

SCRIPT_ROOT="$(pwd `dirname $0`)"
INFLUXDB_VERSION="1.8.10"
INFLUXDB_DATADIR="/data/influxdb"
INFLUXDB_USER="influx"
INFLUXDB_PREFIX="/usr/local/influxdb"
INFLUXDB_PACKAGE="influxdb-1.8.10_linux_amd64"
INFLUXDB_ADMIN_USER='admin'
INFLUXDB_ADMIN_PASS='exbdTV5d*kY96Y$V7228wvNvUTrc7YL8'

influxdb_check() {
    if [ -d "${INFLUXDB_PREFIX}" ];then
        echo -e "\e[33m[WARN ]\e[0m InfluxDB has been installed, please check."
        exit 1
    else
        echo -e "\e[32m[INFO ]\e[0m InfluxDB has not been installed yet, continue."
    fi
}

influxdb_preinstall() {
    echo -e "[\033[32mINFO \033[0m] Create influxdb process user."
    id ${INFLUXDB_USER} > /dev/null 2>&1 || useradd ${INFLUXDB_USER}

    if [ ! -d "${INFLUXDB_DATADIR}" ];then
        echo -e "[\033[32mINFO \033[0m] Create influxdb data directory."
        mkdir -p ${INFLUXDB_DATADIR}/{data,logs}

        echo -e "[\033[32mINFO \033[0m] Set permissions ..."
        chown -R ${INFLUXDB_USER}:${INFLUXDB_USER} ${INFLUXDB_DATADIR}
        chmod -R 750 ${INFLUXDB_DATADIR}
        
        echo -e "[\033[32mINFO \033[0m] Create a symbolic link ..."
        ln -sfT ${INFLUXDB_DATADIR}/data /var/lib/influxdb
        ln -sfT ${INFLUXDB_DATADIR}/logs /var/log/influxdb
    fi
}

influxdb_install() {
    if [ -f "${SCRIPT_ROOT}/files/${INFLUXDB_PACKAGE}.tar.gz" ] && [ ! -e "${INFLUXDB_PREFIX}" ];then
        echo -e "[\033[32mINFO \033[0m] Find binary file, extracting ..."
        tar zxf ${SCRIPT_ROOT}/files/${INFLUXDB_PACKAGE}.tar.gz && mv ${SCRIPT_ROOT}/influxdb-1.8.10-1 ${INFLUXDB_PREFIX}
        chown -R ${INFLUXDB_USER}:${INFLUXDB_USER} ${INFLUXDB_PREFIX}

        echo -e "[\033[32mINFO \033[0m] Configure influxdb.cnf"
        mkdir -p /etc/influxdb
        cp ${SCRIPT_ROOT}/files/influxdb.conf /etc/influxdb/influxdb.conf
    else
        echo -e "\e[32m[ERROR]\e[0m Influxdb binary file is not exists."
        exit 1
    fi
}

influxdb_postinstall() {
    # 设置全局环境变量
    echo "export PATH=/usr/local/influxdb/usr/bin:\$PATH" > /etc/profile.d/influxdb.sh

    # 设置systemd脚本
    cp ${SCRIPT_ROOT}/files/influxdb.service /etc/systemd/system/influxdb.service
    systemctl daemon-reload
    systemctl enable influxdb
    systemctl start influxdb
    systemctl status influxdb

    sleep 30

    # 创建管理员用户
    ${INFLUXDB_PREFIX}/usr/bin/influx -execute "CREATE USER \"${INFLUXDB_ADMIN_USER}\" WITH PASSWORD '${INFLUXDB_ADMIN_PASS}' WITH ALL PRIVILEGES"

}

# influxdb_check
influxdb_preinstall
influxdb_install
influxdb_postinstall
