FROM harbor.189ip.cn:18000/gysk_basis/alpine:3.15

RUN apk update && apk upgrade
RUN apk add openssl curl ca-certificates
RUN printf "%s%s%s%s\n" \
        "@nginx " \
        "http://nginx.org/packages/alpine/v" \
        `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
        "/main" | tee -a /etc/apk/repositories
RUN curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub
RUN openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout
RUN mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/
RUN apk add --no-cache nginx@nginx

RUN adduser -D www
COPY ./etc/nginx.conf /etc/nginx/
RUN chmod 644 /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/http.d && mkdir -p /etc/nginx/stream.d
# RUN rm -rf /etc/nginx/conf.d

ENTRYPOINT ["nginx", "-g", "daemon off;"]
