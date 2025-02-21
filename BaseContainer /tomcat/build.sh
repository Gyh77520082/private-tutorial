#!/usr/bin/env bash
#

export BUILDKIT_NO_CLIENT_TOKEN=1

VERSION="9.0.98"
FILENAME="apache-tomcat-${VERSION}.tar.gz"

if [ ! -f "$FILENAME" ];then
    curl "http://10.10.114.7/resources/tomcat/apache-tomcat-${VERSION}.tar.gz" -O $FILENAME
fi

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t harbor.189ip.cn:18000/gysk_basis/tomcat:latest-jdk8 \
    -t harbor.189ip.cn:18000/gysk_basis/tomcat:9.0.98-jdk8 \
    -t harbor.189ip.cn:18000/gysk_basis/tomcat:9.0-jdk8 \
    --push \
    .
