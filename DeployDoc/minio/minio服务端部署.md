# 从二进制文件安装MinIO

## 环境准备

在开始安装之前，请确保您的系统满足以下要求：
- 操作系统：Linux
- 用户权限：root 或 sudo 权限

### 新增用户并创建挂载的目录

```shell
# 新增用户并创建挂载的目录
useradd -M -r minio-user
mkdir -p /usr/local/minio/{bin,etc,certs,logs}
mkdir /data/minio
chown -R minio-user.minio-user /data/minio

cat > /usr/local/minio/etc/minio.env <<EOF
MINIO_LOG_PATH="/usr/local/minio/logs"
MINIO_VOLUMES="http://10.10.114.4{7...9}:9000/data/minio"
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=Gysk@1357911
MINIO_SERVER_URL=""
# MINIO_SERVER_POOL=""
MINIO_OPTS="--console-address :9001"
EOF
```

### 下载并安装MinIO

```shell
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
mkdir -p /usr/local/minio/bin
mv minio /usr/local/minio/bin
```

### 注册成服务给system托管

```shell
cat >/etc/systemd/system/minio.service <<EOF
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/minio/bin/minio

[Service]
WorkingDirectory=/data

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=-/usr/local/minio/etc/minio.env
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /usr/local/minio/etc/minio.env\"; exit 1; fi"
ExecStart=/usr/local/minio/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemctl setups where other services use `After=minio.server`
# Uncomment the line to enable the functionality
# Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for ${project.name}-${project.version} (${project.name})
EOF
```

## 启动MinIO服务

```shell
systemctl start minio
```

## 页面访问

MinIO控制台可以通过以下地址访问：
```
http://<您的服务器IP>:9001
```
例如，如果您的服务器IP是192.168.1.100，则访问地址为：
```
http://192.168.1.100:9001
```

## 参考文档

更多详细信息，请参考 [MinIO官方文档](https://min.io/docs/minio/linux/index.html)。