#!/usr/bin/env bash
# Description: 
# Author: .Rody
# Date: 2025-01-06 14:37:13

MYSQL_VERSION="mysql-8.0.37-linux-glibc2.12-x86_64"
MYSQL_BASEDIR="/usr/local/mysql"
MYSQL_DATADIR="/data/mysql"
MYSQL_CLIENT="${MYSQL_BASEDIR}/bin/mysql -uroot "
MYSQL_ROOT_PASS='7KST2Ly@c@Z%H2uKMB7qHNpwnY!VcvpY'
MYSQL_ADMIN_PASS='c6^gpz!T6qHeRsf8'
MYSQL_INNODB_BUFFER_POOL=0.7
SCRIPT_ROOT="$(pwd `dirname $0`)"

MYSQL_ADMIN_NETWORK=$1
if [ -n "${MYSQL_ADMIN_NETWORK}" ];then
    echo ${MYSQL_ADMIN_NETWORK} | grep -Eo '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(%)' > /dev/null 2>&1
    if [ $? -ne 0 ];then
        echo -e "\033[33m[WARN ]\033[0m \$1 format like 192.168.1.%"
    fi
else
    echo -e "[\033[31mERROR\033[0m] \$1 cannot be empty."
    echo -e "[\033[33mWARN \033[0m] \$1 format like 192.168.1.%"
    exit 1
fi

mysql_check() {
    if [ -e "${MYSQL_DATADIR}" ];then
        echo -e "[\033[33mWARN \033[0m] ${MYSQL_DATADIR} is exists."
    fi

    if [ -e "${MYSQL_BASEDIR}" ];then
        echo echo -e "[\033[33mWARN \033[0m] ${MYSQL_DATADIR} is exists."
    fi
}

mysql_preinstall() {
    # 依赖
    yum install -y libaio libnuma

    # 进程运行用户
    echo -e "[\033[32mINFO \033[0m] Create mysql process user."
    [ id mysql > /dev/null 2>&1 ] || useradd -r -M -s /bin/false mysql

    # 数据目录
    if [ ! -d "${MYSQL_DATADIR}" ];then
        echo -e "[\033[32mINFO \033[0m] Create mysql data directory."
        mkdir -p ${MYSQL_DATADIR}/{logs,data,tmp}
        chown -R mysql.mysql ${MYSQL_DATADIR}
        chmod -R 750 ${MYSQL_DATADIR}
    fi
}

mysql_install() {
    if [ -f "${SCRIPT_ROOT}/files/${MYSQL_VERSION}.tar.xz" ];then
        echo -e "[\033[32mINFO \033[0m] Find binary file, extracting ..."
        tar Jxf ${SCRIPT_ROOT}/files/${MYSQL_VERSION}.tar.xz -C /usr/local
        if [ $? -eq 0 ];then
            echo -e "[\033[32mINFO \033[0m] Extract successful."
        else
            echo -e "[\033[31mERROR\033[0m] Extract failed. exit code: $?."
            exit
        fi

        echo -e "[\033[32mINFO \033[0m] Create a symbolic link ..."
        ln -s /usr/local/${MYSQL_VERSION} /usr/local/mysql

        echo -e "[\033[32mINFO \033[0m] Set permissions ..."
        chown -R mysql.mysql /usr/local/mysql*

        echo -e "[\033[32mINFO \033[0m] Configure my.cnf"
        mysql_config
        cp ${SCRIPT_ROOT}/files/my8.0.cnf /etc/my.cnf

        echo -e "[\033[32mINFO \033[0m] Initialize mysql server system database ..."
        ${MYSQL_BASEDIR}/bin/mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql
        if [ $? -eq 0 ];then
            echo -e "[\033[32mINFO \033[0m] initialize successful."
        else
            echo -e "[\033[31mERROR\033[0m] initialize failed, please check."
            exit 1
        fi
    else
        echo -e "[\033[31mERROR\033[0m] ${MYSQL_VERSION}.tar.xz is not exists. please put on files directory."
        exit 1
    fi
}

mysql_config() {
    echo -e "[\033[32mINFO \033[0m] Changing my.cnf."

    MYSQL_CPU=$(cat /proc/cpuinfo | grep -c processor)
    MYSQL_MEM=$(echo "$(cat /proc/meminfo | grep MemTotal | awk '{print $2}') * ${MYSQL_INNODB_BUFFER_POOL} / 1024" | bc)
    MYSQL_SERVER_ID=$(ip addr | grep eth0 | awk 'match($0, /((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/, a) {print a[0]}' | sed 's/\.//g')
    
    sed -i "s/innodb_buffer_pool_size.*/innodb_buffer_pool_size = ${MYSQL_MEM}M/g" ${SCRIPT_ROOT}/files/my8.0.cnf
    sed -i "s/innodb_buffer_pool_instances.*/innodb_buffer_pool_instances = ${MYSQL_CPU}/g" ${SCRIPT_ROOT}/files/my8.0.cnf
    sed -i "s/server-id.*/server-id = ${MYSQL_SERVER_ID}/g" ${SCRIPT_ROOT}/files/my8.0.cnf
}

mysql_postinstall() {
    # 添加到系统PATH
    local MYSQL_PATH_SEARCH="/etc/profile.d/mysql.sh"
    if [ ! -f "${MYSQL_PATH_SEARCH}" ];then
        echo "export PATH="/usr/local/mysql/bin:\$PATH"" > ${MYSQL_PATH_SEARCH}
    fi

    # 添加到系统lib查找路径
    local MYSQL_LIB_SEARCH="/etc/ld.so.conf.d/mysql-x86_64.conf"
    if [ ! -f "${MYSQL_LIB_SEARCH}" ];then
        echo "/usr/local/mysql/lib" > ${MYSQL_LIB_SEARCH}
    fi

    # 创建systemd脚本
    cp ${SCRIPT_ROOT}/files/mysqld.service /etc/systemd/system/mysqld.service
    systemctl daemon-reload

    # 设置开机自启动，并启动服务
    systemctl enable mysqld
    systemctl start mysqld
    sleep 30
    systemctl status mysqld
}

mysql_postsetting() {
    echo -e "[\033[32mINFO \033[0m] Add custome user."
    ${MYSQL_CLIENT} -e "
        CREATE USER IF NOT EXISTS ffcsdba@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';
        GRANT ALL PRIVILEGES ON *.* TO ffcsdba@'localhost' WITH GRANT OPTION;

        CREATE USER IF NOT EXISTS rffcsdba@'${MYSQL_ADMIN_NETWORK}' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';
        GRANT ALL PRIVILEGES ON *.* TO rffcsdba@'${MYSQL_ADMIN_NETWORK}' WITH GRANT OPTION;

        CREATE USER IF NOT EXISTS backup@'localhost' IDENTIFIED BY 'vn7xJc5LnG3@2JzX';
        GRANT SELECT, SHOW VIEW, EVENT, PROCESS, LOCK TABLES, REPLICATION CLIENT, RELOAD ON *.* TO backup@'localhost';

        CREATE USER IF NOT EXISTS repl@'${MYSQL_ADMIN_NETWORK}' IDENTIFIED BY 'yQ*qcVLLuPxVA5!m';
        GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO replicator@'${MYSQL_ADMIN_NETWORK}';

        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASS}';

        FLUSH PRIVILEGES;
    "
}

# mysql_check
mysql_preinstall
mysql_install
mysql_postinstall
mysql_postsetting
