#!/usr/bin/env bash
#

export BUILDKIT_NO_CLIENT_TOKEN=1

VERSION="3.6.3"
FILENAME="apache-maven-${VERSION}-bin.tar.gz"

if [ ! -f "$FILENAME" ];then
    curl "http://10.10.114.7/resources/maven/apache-maven-${VERSION}-bin.tar.gz" -O $FILENAME
fi

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t harbor.189ip.cn:18000/gysk_basis/maven:latest-jdk8 \
    -t harbor.189ip.cn:18000/gysk_basis/maven:3.6.3-jdk8 \
    -t harbor.189ip.cn:18000/gysk_basis/maven:3.6-jdk8 \
    --push \
    .
