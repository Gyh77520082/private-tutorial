# OpenResty 部署指南

此指南将帮助您使用 `docker-compose` 部署 OpenResty。

## 前提条件

- Docker 已安装
- Docker Compose 已安装

## 步骤

1. 克隆此存储库到您的本地机器。

```sh
git clone <repository-url>
cd /workspaces/private-tutorial/DeployDoc/openrestry
```

2. 创建必要的目录和文件。

```sh
mkdir html logs
touch nginx.conf
```

3. 编辑 `nginx.conf` 文件以配置 OpenResty。

4. 使用 `docker-compose` 启动服务。

```sh
docker-compose up -d
```

5. 访问您的服务器以查看 OpenResty 是否已成功部署。

- http://localhost:80
- https://localhost:443

## 目录结构

```
/workspaces/private-tutorial/DeployDoc/openrestry
├── docker-compose.yml
├── html
├── logs
└── nginx.conf
```

## 其他

有关 OpenResty 的更多信息，请访问 [OpenResty 官方网站](https://openresty.org/).
