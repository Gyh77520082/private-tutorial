FROM harbor.189ip.cn:18000/gysk_basis/alpine:3.15

RUN apk update && apk upgrade
RUN apk add --no-cache openjdk8
RUN apk add --no-cache ca-certificates tree tini
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/default-jvm/bin