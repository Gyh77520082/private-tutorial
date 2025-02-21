FROM alpine:3.15

RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.15/main" > /etc/apk/repositories \
    && echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.15/community" >> /etc/apk/repositories \
    && echo "https://mirror.tuna.tsinghua.edu.cn/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update
RUN apk add --no-cache curl bash tzdata
RUN apk add --no-cache busybox-extras

RUN ln -s /bin/busybox-extras /bin/telnet