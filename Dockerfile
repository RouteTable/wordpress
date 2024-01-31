FROM arm64v8/alpine:3.14
MAINTAINER Etopian Inc. <contact@etopian.com>


LABEL   devoply.type="site" \
        devoply.cms="wordpress" \
        devoply.framework="wordpress" \
        devoply.language.name="php" \
        devoply.language.version="8.1" \
        devoply.require="mariadb nginxproxy/acme-companion nginxproxy/acme-companion" \
        devoply.recommend="redis" \
        devoply.description="WordPress on Nginx and PHP-FPM with WP-CLI." \
        devoply.name="WordPress" \
        devoply.params="docker run -d --name {container_name} -e VIRTUAL_HOST={virtual_hosts} -v /data/sites/{domain_name}:/DATA etopian/alpine-php8.1-wordpress" \
        php.version=8.1


RUN  apk update \
        && apk add --no-cache \
        bash \
        dcron \
        less \
        vim \
        openssl \
        nginx \
        shadow \
        s6 \
        logrotate \
        gettext \
        bash-completion \
        curl \
        mariadb-client \
        openssh-client \
        git \
        curl \
        rsync \
        tar \
        musl \
        ca-certificates \
        php8-apcu \
        php8-dev \
        php8-bcmath \
        php8-fpm \
        php8-ctype \
        php8-curl \
        php8-dom \
        php8-gd \
        php8-gettext \
        php8-gmp \
        php8-iconv \
        php8-intl \
        php8-json \
        php8-mysqli \
        php8-openssl \
        php8-opcache \
        php8-pdo \
        php8-pdo_mysql \
        php8-pear \
        php8-pgsql \
        php8-phar \
        php8-exif \
        phpp-xmlreader \
        php8-xml \
        php8-xsl \
        php8-dom \
        php8-zip \
        php8-dev \
        php8-mbstring \
        php8-session \
        php8-apcu \
        php8-simplexml \
        php8-sodium \
        php8-zlib \
        build-base && \
        rm -rf /etc/nginx/* && \
        mkdir /etc/logrotate.docker.d && \
        pecl81 install redis && \
        apk del build-base && \
        apk del php81-dev && \
        apk del php81-pear && \
        rm -rf /var/cache/apk/*

ENV PATH="/DATA/bin:$PATH" \
    TERM="xterm" \
    DB_HOST="172.17.0.1" \
    DB_NAME="" \
    DB_USER="" \
    DB_PASS="" \
    DB_HOST="" \
    PHP_MEMORY_LIMIT=128M \
    PHP_POST_MAX_SIZE=2G \
    PHP_UPLOAD_MAX_FILESIZE=2G \
    PHP_MAX_EXECUTION_TIME=3600 \
    PHP_MAX_INPUT_TIME=3600 \
    PHP_DATE_TIMEZONE=UTC \
    PHP_LOG_LEVEL=warning \
    PHP_MAX_CHILDREN=25 \
    PHP_MAX_REQUESTS=500 \
    PHP_PROCESS_IDLE_TIMEOUT=10s \
    NGINX_WORKER_PROCESSES="auto" \
    NGINX_WORKER_CONNECTIONS=4096 \
    NGINX_SENDFILE=on \
    NGINX_TCP_NOPUSH=on \
    REDIS_HOST=172.17.0.1 \
    REDIS_PORT=6379 \
    REDIS_DB=0

ADD rootfs /

RUN sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/DATA:\/bin\/bash/g" /etc/passwd && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/DATA:\/bin\/bash/g" /etc/passwd- && \
    chmod +x /usr/bin/wp-config-devoply && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/bin/wp && \
    chown nginx:nginx /usr/bin/wp && \
    mkdir -p /DATA/htdocs && \
    mkdir -p /DATA/logs/nginx && \
    mkdir -p /DATA/logs/php-fpm && \
    chown -R nginx:nginx /DATA

EXPOSE 80

VOLUME ["/DATA"]


CMD ["/bin/s6-svscan", "/etc/s6"]
