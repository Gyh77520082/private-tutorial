# MinIO Docker Compose 部署

此项目使用 Docker Compose 部署 MinIO。

## 部署步骤

1. 确保已安装 Docker 和 Docker Compose。
2. 在终端中导航到项目目录。
3. 运行以下命令启动 MinIO 服务：
   ```sh
   docker-compose up -d
   ```
4. MinIO 管理界面可以通过浏览器访问 `http://localhost:9001`，默认用户名和密码均为 `minioadmin`。

## 服务信息

- MinIO 端口：9000
- MinIO 管理界面端口：9001
- 默认用户名：minioadmin
- 默认密码：Gysk@135.com

## 数据持久化

MinIO 数据将持久化到主机的 `/data/minio/data` 目录。