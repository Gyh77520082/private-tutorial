# centos7安装openresty

## 安装前置开发库

```shell
yum install pcre-devel openssl-devel gcc curl -y
```

确保所有库都已成功安装。

## 使用yum安装

首先，下载并配置OpenResty的yum仓库：

```shell
wget https://openresty.org/package/centos/openresty.repo
cat > openresty.repo << REPO
[openresty]
name=Official OpenResty Open Source Repository for CentOS
baseurl=https://openresty.org/package/centos/$releasever/$basearch
skip_if_unavailable=False
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://openresty.org/package/pubkey.gpg
enabled=1
enabled_metadata=1
REPO
mv openresty.repo /etc/yum.repos.d/openresty.repo
```

然后，更新yum缓存并安装OpenResty：

```shell
yum check-update
yum install -y openresty
```

## 验证安装

安装完成后，可以通过以下命令验证OpenResty是否安装成功：

```shell
openresty -v
```

如果安装成功，你将看到OpenResty的版本信息。

## 启动和停止OpenResty

启动OpenResty：

```shell
systemctl start openresty
```

停止OpenResty：

```shell
systemctl stop openresty
```

设置开机自启动：

```shell
systemctl enable openresty
```

## 配置文件位置

OpenResty的默认配置文件位于：

```shell
/etc/openresty/nginx.conf
```

你可以根据需要修改此文件来配置OpenResty。