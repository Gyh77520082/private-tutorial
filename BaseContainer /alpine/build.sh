#!/usr/bin/env bash
# Description: 同时构建AMD64和ARM64双架构的基础系统镜像

export BUILDKIT_NO_CLIENT_TOKEN=1

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t harbor.189ip.cn:18000/gysk_basis/alpine:3.15.11 \
    -t harbor.189ip.cn:18000/gysk_basis/alpine:3.15 \
    -t harbor.189ip.cn:18000/gysk_basis/alpine:latest \
    --push \
    .
