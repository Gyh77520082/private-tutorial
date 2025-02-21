# Containers

主要包含的内容是镜像构建的相关资源

## 镜像说明

### 基础镜像

> 最基本的系统镜像，预装了常用工具，如果需要添加所有镜像需要的命令，请先更新它！

- alpine

### 服务器镜像

> 这些具体的服务器镜像都是已经上述的基础镜像alpine为准，另外安装自己需要的环境

- nginx
- nginx-php
- openjdk
- openjdk-chrome
- tome

## Docker构建云（多架构）

- 以下拉取的镜像，必要时，需要开启科学上网，否则可能拉不下来

### 环境搭建

## 多架构构建（模拟器）

```sh
# 安装模拟器
docker pull tonistiigi/binfmt
docker run --privileged --rm tonistiigi/binfmt --install all

## 创建构建器
docker buildx create --name qemu-builder \
    --platform linux/arm64,linux/armd64 \
    --bootstrap \
    --use
```

## 多架构构建（原生远程节点）

```sh
# 创建构建器
docker buildx create --use --name native-builder

## 追加节点
## node-arm64和node-amd64是远程docker节点的hostname，需要能ping通
## 且需要开启2375端口
docker buildx create --append --name native-builder node-arm64
docker buildx create --append --name native-builder node-amd64
```

### 多架构构建输出

```sh
# --push在buildx下才可用，此种推送方式不会在本地产生镜像
docker buildx build \
  --builder <YOUR-BUILDER> \
  --platform linux/amd64,linux/arm64 \
  --tag IMAGE_NAME \
  --push .
```
