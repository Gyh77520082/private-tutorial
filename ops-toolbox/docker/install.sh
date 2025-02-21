#!/usr/bin/env bash
# Description: 二进制离线安装Docker
# Author: .Rody
# Date: 2025-01-09 16:10:37

DOCKER_VERSION="27.4.1"
SCRIPT_ROOT="$(pwd `dirname $0`)"

docker_check() {
    DOCKER_PROC_NUM=$(ps -ef | grep -v grep | grep -c dockerd)
    if [ ${DOCKER_PROC_NUM} -ne 0 ];then
        echo -e "[\033[31mERROR\033[0m] dockerd has been running, installation cancel."
        exit
    fi

    if [ -e "/usr/bin/docker" ] || [ -e "/usr/bin/containerd" ] || [ -e "/usr/bin/dockerd" ];then
        echo -e "[\033[31mERROR\033[0m] docker maybe installed. please check it."
        exit
    fi
}

docker_preinstall() {
    echo -e "[\033[32mINFO \033[0m] Create docker group."
    [ groups docker > /dev/null 2>&1 ] || groupadd docker
}

docker_install() {
    if [ -f "${SCRIPT_ROOT}/files/docker-${DOCKER_VERSION}.tgz" ];then
        echo -e "[\033[32mINFO \033[0m] Find binary file, extracting ..."
        tar zxvf ${SCRIPT_ROOT}/files/docker-${DOCKER_VERSION}.tgz
        cp ${SCRIPT_ROOT}/docker/* /usr/bin

        # plugin: compose
        if [ -e "${SCRIPT_ROOT}/files/docker-compose-linux-x86_64" ];then
            mkdir -p /usr/local/lib/docker/cli-plugins
            cp ${SCRIPT_ROOT}/files/docker-compose-linux-x86_64 /usr/local/lib/docker/cli-plugins/docker-compose
            chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        else
            echo -e "\033[33m[WARN ]\033[0m docker-compose-linux-x86_64 binary not found. continue ..."
        fi
    else
        echo -e "[\033[31mERROR\033[0m] docker-${DOCKER_VERSION}.tgz is not exists. please put on files directory."
        exit
    fi
}

docker_config() {
    mkdir -p /etc/docker
    mkdir -p /data/docker
    ln -s /data/docker /var/lib/docker
    cp ${SCRIPT_ROOT}/files/daemon.json /etc/docker/daemon.json
}

docker_postinstall() {
    echo -e "[\033[32mINFO \033[0m] Create systemd script ..."
    cp ${SCRIPT_ROOT}/files/containerd.service /etc/systemd/system/containerd.service
    cp ${SCRIPT_ROOT}/files/docker.service /etc/systemd/system/docker.service
    cp ${SCRIPT_ROOT}/files/docker.socket /etc/systemd/system/docker.socket

    systemctl daemon-reload
    systemctl enable docker
    systemctl start docker
    sleep 30
    systemctl status docker
}


docker_check
docker_preinstall
docker_install
docker_config
docker_postinstall
