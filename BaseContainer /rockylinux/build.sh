#!/usr/bin/env bash
# Description: 同时构建AMD64和ARM64双架构的基础系统镜像

export BUILDKIT_NO_CLIENT_TOKEN=1

docker buildx prune -a -f

# minimal
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg VERSION="8.9-minimal" \
    -t harbor.189ip.cn:18000/gysk_basis/rockylinux:8.9-minimal \
    -t harbor.189ip.cn:18000/gysk_basis/rockylinux:8-minimal \
    --push \
    .

# # full
# docker buildx build \
#     --platform linux/amd64,linux/arm64 \
#     --build-arg VERSION="8.9" \
#     -t harbor.189ip.cn:18000/gysk_basis/rockylinux:8.9 \
#     -t harbor.189ip.cn:18000/gysk_basis/rockylinux:8 \
#     --push \
#     .