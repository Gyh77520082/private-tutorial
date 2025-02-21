#!/bin/bash

#环境检查
function Check_environment() {

    Kernel_Version=`uname -r | awk -F '.' '{print $1}'`
    Kernel_Issue=`uname -r | awk -F '.' '{print $2}'`
    if [[ $Kernel_Version -lt  3 ]]; then
        if [[ $Kernel_Issue -lt 10 ]]; then

            echo "当前操作系统内核为：${Kernel_Version},小于Docker所需的3.10版本请更新内核。";
            exit 0;
        fi
         
    fi

}

#安装docker和docker composer
function Install_Docker() {

    echo "检查Docker是否已安装……"
    docker -v

    if [ $? -ne  0 ]; then
        echo "检测到Docker未安装！"
        echo
        echo " ***** 开始安装 docker 工具 ***** "
        yum install -y yum-utils device-mapper-persistent-data lvm2 --skip-broken
        yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        sed -i 's/download.docker.com/mirrors.aliyun.com\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo
        yum makecache
        yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        #yum install -y docker-ce
        systemctl start docker
        echo " ***** 安装 docker 工具完成 ***** "
    else
        echo "docker 已安装！"
    fi
    docker compose version
    if [ $? -ne  0 ]; then
        echo "检测到docker-compsoe未安装！"
        echo
        echo " ***** 开始安装 docker-compsoe ***** "
cat > docker-compsoer.sh <<EOF
#!/bin/bash
curl -L https://get.daocloud.io/docker/compose/releases/download/v2.12.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose 
chmod +x /usr/local/bin/docker-compose 
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose 
#docker compose version 
EOF
         sh docker-compsoer.sh
         echo " ***** 安装 docker-compsoer ***** "
    else
         echo "docker-compsoer已安装"
    fi
}

#配置仓库加速以解决私有仓库https验证
function Docker_Warehouse() {
cat > /etc/docker/daemon.json <<EOF
{
"registry-mirrors":[
        "https://uxk0ognt.mirror.aliyuncs.com",
        "https://at9hea2o.mirror.aliyuncs.com",
        "http://registry.docker-cn.com",
        "http://docker.mirrors.ustc.edu.cn"
        ],
"insecure-registries":[
        "27.156.9.100:8088"
        ]
}
EOF
#重载reload配置文件 
systemctl daemon-reload 
#重启docker服务 
systemctl restart docker
#登录 
docker login 27.156.9.100:8088 -uadmin -p $1
}





