#!/usr/bin/env bash
# Description: Install RabbitMQ for version 3.11.28
# Date: 2025-01-09 15:00:00

#######test#####
# centos7.9 3.10.0 PASS
# centos8.1 4.18.0 PASS, 如果底层系统包有很多问题，可以使用RPM安装erlang

# 全局设置
DOWNLOAD_FLAG="false"
MQ_VERSION="3.11.28"
ERLANG_VERSION="25.2"
MQ_BASEDIR="/usr/local/rabbitmq"
MQ_DATADIR="/data/mysql"
MQ_ADMIN_PASS='xxxxxx'
SCRIPT_ROOT="$(pwd `dirname $0`)"


# 脚本开始
echo "RabbitMQ ${MQ_VERSION} 和 Erlang ${ERLANG_VERSION} 源码安装脚本"

config_rabbitmq() {

    sleep 5
    cd ${MQ_BASEDIR}/sbin

    # 启用 RabbitMQ 管理插件
    ./rabbitmq-plugins enable rabbitmq_management

    # 添加admin用户
    ./rabbitmqctl add_user admin ${MQ_ADMIN_PASS}
    ./rabbitmqctl set_user_tags admin administrator
    ./rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

}

# 卸载 Erlang 方法
uninstall_erlang() {
    mv /usr/local/erlang /usr/local/erlang.`date +%Y%m%d%H%M%S`
    sed -i '/\/usr\/local\/erlang\/bin/d' /etc/profile
    source /etc/profile
}

# 卸载 RabbitMQ 方法
uninstall_rabbitmq() {
    ${MQ_BASEDIR}/sbin/rabbitmqctl stop
    mv ${MQ_BASEDIR} ${MQ_BASEDIR}.`date +%Y%m%d%H%M%S`
    
    if [ -d "/data/rabbitmq/mnesia" ]; then
        mv /data/rabbitmq/mnesia /data/rabbitmq/mnesia.`date +%Y%m%d%H%M%S`
    fi
    
    sed -i '/\/usr\/local\/rabbitmq\/sbin/d' /etc/profile
    source /etc/profile
}

# 环境检查
pre_check() {
    echo "检查环境是否已安装rabbitmq..."
    if [ -d "${MQ_BASEDIR}" ]; then
        echo "RabbitMQ已经安装，请先卸载后再安装..."
        exit 1
    fi

    echo "检查环境端口是否占用"
    if [ -n "$(netstat -tuln | grep :5672)" ]; then
        echo "5672端口已被占用，请检查..."
        exit 1
    fi

    if [ ! -d "${SCRIPT_ROOT}/files" ]; then
        echo "正在创建安装包目录..."
        mkdir -p "${SCRIPT_ROOT}"/files
    fi
}

# 安装前的准备工作
pre_install() {
    echo "正在安装依赖..."
    # 对于不用系统，这块需要注意
    yum install -y make perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel ncurses ncurses-devel openssl openssl-devel autoconf unixODBC unixODBC-devel wxBase wxGTK SDL wxGTK-gl
    #yum install -y openssl-devel unixODBC-devel gcc gcc-c++ wxWidgets compat-openssl10 libnsl ncurses-compat-libs make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel java-devel
    echo "依赖安装完成！"
}

# 安装Erlang的方法
install_erlang() {

    local erlang_tarball="otp-OTP-${ERLANG_VERSION}.tar.gz"
    local erlang_dir="otp-OTP-${ERLANG_VERSION}"

    cd "${SCRIPT_ROOT}/files"

    if [ ${DOWNLOAD_FLAG} == "true" ]; then
        echo "正在下载Erlang源码包..."
        local erlang_url="https://codeload.github.com/erlang/otp/tar.gz/refs/tags/OTP-${ERLANG_VERSION}"
        wget "${erlang_url}"
    else
        if [ -f "${SCRIPT_ROOT}/files/${erlang_tarball}" ];then
            echo "已经下载过Erlang源码包，跳过下载..."
        else
            echo "Erlang源码包不存在，请设置DOWNLOAD_FLAG为true重新下载或者上传对应的包..."
            exit 1
        fi
    fi

    tar -zxf "${erlang_tarball}"
    cd "${erlang_dir}"

    echo "正在配置Erlang安装..."
    ./configure --prefix=/usr/local/erlang

    echo "正在编译Erlang..."
    make -j 4

    echo "正在安装Erlang..."
    make -j 4 install

    ln -sf /usr/local/erlang/bin/erl /usr/bin/erl 
    echo 'export ERLANG_HOME=/usr/local/erlang/' >> /etc/profile
    echo "export PATH=\$PATH:$ERLANG_HOME/bin" >> /etc/profile
    source /etc/profile

    cd "${SCRIPT_ROOT}/files"
    rm -rf "${erlang_dir}"
}

# 安装RabbitMQ的方法
install_rabbitmq() {
    local rabbitmq_tarball="rabbitmq-server-generic-unix-${MQ_VERSION}.tar.xz"
    local rabbitmq_dir="rabbitmq_server-${MQ_VERSION}"

    cd "${SCRIPT_ROOT}/files"

    if [ ${DOWNLOAD_FLAG} == "true" ]; then
        local rabbitmq_url="https://github.com/rabbitmq/rabbitmq-server/releases/download/v${MQ_VERSION}/${rabbitmq_tarball}"
        echo "正在下载RabbitMQ源码包..."
        wget "${rabbitmq_url}"
    else
        if [ -f "${SCRIPT_ROOT}/files/${rabbitmq_tarball}" ];then
            echo "已经下载过RabbitMQ源码包，跳过下载..."
        else
            echo "RabbitMQ源码包不存在，请设置DOWNLOAD_FLAG为true重新下载或者上传对应的包..."
            exit 1
        fi
    fi
    
    tar -Jxvf "${rabbitmq_tarball}"
    mv "${rabbitmq_dir}" /usr/local/rabbitmq

    cd /usr/local/rabbitmq
    cp ${SCRIPT_ROOT}/files/rabbitmq-env.conf ${MQ_BASEDIR}/etc/rabbitmq/rabbitmq-env.conf
    cp ${SCRIPT_ROOT}/files/rabbitmq.conf ${MQ_BASEDIR}/etc/rabbitmq/rabbitmq.conf

    echo 'export RABBITMQ_HOME=/usr/local/rabbitmq' >> /etc/profile
    echo "export PATH=\$PATH:$RABBITMQ_HOME/sbin" >> /etc/profile
    source /etc/profile
}

# 设置RabbitMQ为系统服务并启动的方法
start_rabbitmq_service() {
    echo "正在启动RabbitMQ服务..."
    ${MQ_BASEDIR}/sbin/rabbitmq-server -detached
}

# 主执行逻辑
pre_check
pre_install
install_erlang
install_rabbitmq
start_rabbitmq_service
config_rabbitmq

echo "RabbitMQ 安装和启动完成！"