#!/usr/bin/env bash
#

export BUILDKIT_NO_CLIENT_TOKEN=1

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg="VERSION=1.24.0" \
    -t harbor.189ip.cn:18000/gysk_basis/nginx:1.24.0 \
    -t harbor.189ip.cn:18000/gysk_basis/ff-home-nginx:1.24.0 \
    -t harbor.189ip.cn:18000/gysk_basis/nginx:latest \
    --push \
    .
