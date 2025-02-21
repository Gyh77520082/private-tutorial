#!/usr/bin/env bash
#

export BUILDKIT_NO_CLIENT_TOKEN=1

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg="VERSION=1.8.0_392" \
    -t harbor.189ip.cn:18000/gysk_basis/openjdk-chrome:1.8.0_392 \
    -t harbor.189ip.cn:18000/gysk_basis/openjdk-chrome:8-latest \
    --push \
    .
