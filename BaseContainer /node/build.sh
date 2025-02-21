#!/usr/bin/env bash
#

export BUILDKIT_NO_CLIENT_TOKEN=1

VERSION="v14.21.3"
FILENAME="node-${VERSION}-linux-x64.tar.gz"

if [ ! -f "$FILENAME" ];then
    curl "http://10.10.114.7/resources/node/node-${VERSION}-linux-x64.tar.gz" -O $FILENAME
    curl "http://10.10.114.7/resources/node/node-${VERSION}-linux-arm64.tar.gz" -O $FILENAME
fi

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag harbor.189ip.cn:18000/gysk_basis/node:latest \
    --tag harbor.189ip.cn:18000/gysk_basis/node:14.21 \
    --tag harbor.189ip.cn:18000/gysk_basis/node:14.21.3 \
    --push \
    .
