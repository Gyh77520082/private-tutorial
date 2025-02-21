FROM harbor.189ip.cn:18000/gysk_basis/alpine:3.15

RUN apk update && apk upgrade
RUN apk add openssl curl ca-certificates

# Nginx
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
COPY ./etc/nginx//nginx.conf /etc/nginx/
RUN chmod 644 /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/conf.d && mkdir -p /etc/nginx/stream.d

# PHP7
RUN apk add --no-cache \
    php7-fpm\
    php7 \
    php7-dev \
    php7-apcu \
    php7-bcmath \
    php7-xmlwriter \
    php7-ctype \
    php7-curl \
    php7-exif \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-mbstring\
    php7-opcache \
    php7-openssl \
    php7-pcntl \
    php7-pdo \
    php7-mysqlnd \
    php7-mysqli \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-phar \
    php7-posix \
    php7-session \
    php7-xml \
    php7-simplexml \
    php7-mcrypt \
    php7-xsl \
    php7-zip \
    php7-zlib \
    php7-dom \
    php7-redis\
    php7-tokenizer \
    php7-gd \
    php7-mongodb\
    php7-fileinfo \
    php7-zmq \
    php7-memcached \
    php7-xmlreader
RUN mkdir -p /usr/local/var/log/php7/
RUN mkdir -p /usr/local/var/run/
COPY ./etc/php/php-fpm.conf /etc/php7/
COPY ./etc/php/www.conf /etc/php7/php-fpm.d/

# Crond
COPY ./crontabs/default /var/spool/cron/crontabs/
RUN cat /var/spool/cron/crontabs/default >> /var/spool/cron/crontabs/root
RUN mkdir -p /var/log/cron \
 && touch /var/log/cron/cron.log

# Supervisor
RUN apk add supervisor
COPY ./etc/supervisor/conf.d/ /etc/supervisor/conf.d/

# entrypoint
COPY ./entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["sh","/docker-entrypoint.sh"]
