# OpenTSDB 部署指南

## 使用 Docker Compose 部署

以下是使用 Docker Compose 部署 OpenTSDB 和 HBase 的步骤。

### 步骤 1: 克隆仓库

```sh
git clone <repository-url>
cd <repository-directory>
```

### 步骤 2: 启动服务

使用以下命令启动服务：

```sh
docker-compose up -d
```

### 步骤 3: 验证服务

您可以通过访问以下 URL 验证服务是否正常运行：

- HBase Web UI: `http://localhost:16010`
- OpenTSDB Web UI: `http://localhost:4242`

### 数据持久化

在 `docker-compose.yml` 文件中，我们已经配置了数据卷，以确保 HBase 和 OpenTSDB 的数据在容器重启后不会丢失。

```yaml
services:
  hbase:
    // ...existing code...
    volumes:
      - hbase-data:/data

  opentsdb:
    // ...existing code...
    volumes:
      - opentsdb-data:/data

volumes:
  hbase-data:
  opentsdb-data:
```

这样可以确保数据持久化存储在 Docker 卷中。

### 停止和删除服务

使用以下命令停止并删除服务：

```sh
docker-compose down
```

如果需要删除数据卷，可以使用以下命令：

```sh
docker-compose down -v
```

## 在 CentOS 上进行二进制部署

请参考 [centos二进制部署指南](./centos二进制部署.md) 了解详细步骤。

## 参考

- [OpenTSDB 官方文档](http://opentsdb.net/docs/build/html/index.html)
- [Docker Compose 官方文档](https://docs.docker.com/compose/)
