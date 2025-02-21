#!/usr/bin/env bash
#

export BUILDKIT_NO_CLIENT_TOKEN=1

# Cleanup
docker buildx prune -a -f

# Alpine
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t harbor.189ip.cn:18000/gysk_basis/openjdk:8-latest \
    -f Dockerfile \
    --push \
    .

# RockyLinux
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t harbor.189ip.cn:18000/gysk_basis/openjdk:8-latest-rocky \
    -f Dockerfile-rockylinux \
    --push \
    .
