FROM harbor.189ip.cn:18000/gysk_basis/alpine:3.15

ADD node-v14.21.3-linux-x64.tar.gz /usr/local/
RUN ln -s /usr/local/node-v14.21.3-linux-x64 /usr/local/node
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86_64.so.2

ENV PATH="/usr/local/node/bin:$PATH"