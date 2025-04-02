# RabbitMQ Docker Compose 部署

此项目使用 Docker Compose 部署 RabbitMQ。

## 部署步骤

1. 确保已安装 Docker 和 Docker Compose。
2. 在终端中导航到项目目录。
3. 运行以下命令启动 RabbitMQ 服务：
   ```sh
   docker-compose up -d
   ```
4. RabbitMQ 管理界面可以通过浏览器访问 `http://localhost:15672`，默认用户名和密码均为 `admin`。

## 服务信息

- RabbitMQ 端口：5672
- RabbitMQ 管理界面端口：15672
- 默认用户名：admin
- 默认密码：admin

## 数据持久化

RabbitMQ 数据将持久化到主机的 `/data/rabbitmq/data` 目录。