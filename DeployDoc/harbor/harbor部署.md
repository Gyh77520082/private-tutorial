# 先决条件

Harbor被部署为多个Docker容器。
因此，可以将其部署在任何支持Docker的Linux发行版上。
目标主机需要安装Docker和Docker Compose。

# 硬件需求

下表列出了部署 Harbor 的最低和推荐硬件配置。


| 资源 | 最低 | 推荐  |
| ---- | ---- | ----- |
| CPU  | 2U   | 4U    |
| 内存 | 4GB  | 8GB   |
| 磁盘 | 40GB | 160GB |

# 软件需求

下表列出了目标主机上必须安装的软件版本。


| 软件           | 版本                                                                   | 描述                                     |
| -------------- | ---------------------------------------------------------------------- | ---------------------------------------- |
| docker         | docker 17.06.0-ce+ 或更高版本                                          | 有关安装说明，请参阅 Docker 引擎文档     |
| docker-compose | docker-compose (v1.18.0+) 或 docker-compose v2 (docker-compose-plugin) | 有关安装说明，请参阅 Docker Compose 文档 |

# 开放端口需求


| 端口 | 版本  | 描述                                                                                                   |
| ---- | ----- | ------------------------------------------------------------------------------------------------------ |
| 443  | HTTPS | Harbor 门户和核心 API 在此端口上接受 HTTPS 请求。您可以在配置文件中更改此端口。                        |
| 4443 | HTTPS | 连接到 Harbor 的 Docker Content Trust 服务。只有在启用 Notary 时才需要。您可以在配置文件中更改此端口。 |
| 80   | HTTP  | Harbor 门户和核心 API 在此端口上接受 HTTP 请求。您可以在配置文件中更改此端口。                         |

# 签发证书--公网使用测试网不适用

默认情况下，Harbor 不附带证书。可以在没有安全保护的情况下部署 Harbor，以便您可以通过 HTTP 连接到它。但是，只有在没有连接到外部互联网的气隙测试或开发环境中才可以使用 HTTP。在非气隙环境中使用 HTTP 会使您面临中间人攻击。
在生产环境中，始终使用 HTTPS。如果启用 Content Trust with Notary 以正确签署所有图像，则必须使用 HTTPS。
要配置 HTTPS，您必须创建 SSL 证书。您可以使用由受信任的第三方 CA 签名的证书，也可以使用自签名证书。

## 测试环境生成证书

证数各参数含义如下：
	```
	C-----国家（Country Name）
	ST----省份（State or Province Name）
	L----城市（Locality Name）
	O----公司（Organization Name）
	OU----部门（Organizational Unit Name）
	CN----产品名（Common Name）
	emailAddress----邮箱（Email Address）
	```
### 生成CA证书

#生成私钥。
openssl genrsa -out ca.key 4096
#连接ca证书生成crt文件
openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=FuJian/L=FuZhou/O=FF/OU=YW/CN=10.10.114.28" -key ca.key -out ca.crt
### 生成服务器证书

openssl genrsa -out 10.10.114.28.key 4096
openssl req -sha512 -new -subj "/C=CN/ST=FuJian/L=FuZhou/O=FF/OU=YW/CN=10.10.114.28" -key 10.10.114.28.key -out 10.10.114.28.csr
### 自签署证书

openssl x509 -req -days 36500 -sha256 -extensions req_ext -CA ca.crt -CAkey ca.key -CAcreateserial -in 10.10.114.28.csr -out 10.10.114.28.crt
#### 查看证书内容, 以确保证书生成正确

openssl x509 -noout -text -in 10.10.114.28.crt
### 修改格式并移动证书

mkdir -p /data/harbor/cert cp 10.10.114.28.* /data/harbor/cert/
#将服务器证书yourdomain.com.crt的编码格式转换为yourdomain.com.cert，提供Docker使用
cd /data/harbor/cert/ && openssl x509 -inform PEM -in 10.10.114.28.crt -out 10.10.114.28.cert
# habor安装

## 下载

wget https://github.com/goharbor/harbor/releases/download/v2.9.0/harbor-offline-installer-v2.9.0.tgz
## 安装

tar -zxvf harbor-offline-installer-v2.9.0.tgz && cd harbor
mv harbor.yml.tmpl harbor.yml
mkdir -p /data/harbor
sed -i 's/hostname: reg.mydomain.com/hostname: localhost/g' harbor.yml
sed -i 's/harbor_admin_password: Harbor12345/harbor_admin_password: Gysk@1357911/g' harbor.yml
sed -i 's/password: root123/password: Gysk@1357911/g' harbor.yml
sed -i 's|data_volume: /data|data_volume: /data/harbor|g' harbor.yml

#启动https
sed -i 's|certificate: /your/certificate/path|certificate: /data/harbor/cert/10.10.114.28.cert|g' harbor.yml
sed -i 's|private_key: /your/private/key/path|private_key: /data/harbor/cert/10.10.114.28.key|g' harbor.yml

#执行install脚本 sudo ./install.sh --with-notary --with-trivy
sh install.sh
