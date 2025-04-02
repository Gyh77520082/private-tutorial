# 挂载minio到本地

## 前言

将minio的bucket挂载到本地文件系统

## 环境

客户端系统版本：centos 7
MinIO节点IP：10.10.114.47 10.10.114.48 10.10.114.49

## s3fs方式步骤

```shell
# 安装s3fs客户端（可能需要先安装epel-release）
yum install -y s3fs-fuse
```

### 设置认证

```shell
echo 'gysk:Gysk@1357911' > $HOME/.passwd-s3fs && chmod 600 $HOME/.passwd-s3fs
```

### 挂载

```shell
# 创建本地挂载目录
mkdir -p /data/docker-images
# allow_other: 允许其它用户操作; umask=000，实际上就是权限为777; bucket名为bucket1
s3fs -o passwd_file=$HOME/.passwd-s3fs -o url=http://10.10.114.47:9000 -o allow_other -o nonempty -o no_check_certificate -o use_path_request_style -o umask=000 bucket1 /data/docker-images/
```

### 查看挂载情况

```shell
df -Th
```

### 取消挂载

```shell
fusermount -u /data/docker-images
```

## goofys方式

从github下载二进制包。仓库地址：https://github.com/kahing/goofys

创建用户凭证

```shell
mkdir -p $HOME/.aws
cat >> $HOME/.aws/credentials << EOF
[default]
aws_access_key_id = gysk
aws_secret_access_key = Gysk@1357911
EOF
```

### 挂载

```shell
# endpoint是minio服务端地址 bk1是bucket名 /data/docker-images是本地目录
./goofys --endpoint=http://10.10.114.47:9000 bk1 /data/docker-images
```
