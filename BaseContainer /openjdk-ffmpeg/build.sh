#!/usr/bin/env bash
#

export BUILDKIT_NO_CLIENT_TOKEN=1

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t harbor.189ip.cn:18000/gysk_basis/openjdk-ffmpeg:8-latest \
    --push \
    .
