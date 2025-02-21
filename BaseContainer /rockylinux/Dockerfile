ARG VERSION="latest"
FROM rockylinux:$VERSION

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    -i.bak /etc/yum.repos.d/Rocky-*.repo

RUN microdnf makecache
RUN microdnf install glibc-langpack-en procps which

ENV LANG="en_US.UTF-8"