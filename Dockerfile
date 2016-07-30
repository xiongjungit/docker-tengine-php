FROM       daocloud.io/library/ubuntu:14.04
MAINTAINER xiongjun,dockerxman <fenyunxx@163.com>

ENV NGINX_VERSION tengine-2.1.2
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ADD sources.list /etc/apt/sources.list
RUN apt-get update

RUN apt-get -y install wget gcc g++ make build-essential python


RUN \
  cd /tmp && \
  wget http://npm.taobao.org/mirrors/node/latest/node-v6.3.1.tar.gz && \
  tar xvzf node-v6.3.1.tar.gz && \
  rm -f node-v6.3.1.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm config set registry https://registry.npm.taobao.org && \
  npm install -g npm && \
  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc



RUN apt-get -y install \
	vim \
	unzip \
	curl \
	rsync \
	mysql-client \
	php5 \
	php5-dev \
	php5-fpm \
	php5-mysql \
	php5-pgsql \
	php5-curl \
	php5-mcrypt \
	php5-gd \
	php5-intl \
	php-pear \
	php5-imagick \
	php5-imap \
	php5-memcache \
	php5-ming \
	php5-ps \
	php5-pspell \
	php5-recode \
	php5-sqlite \
	php5-tidy \
	php5-xmlrpc \
	php5-xsl \
	php5-ldap \
	libc-client-dev \
	libmcrypt-dev \
	libssl-dev \
	libpcre3 \
	libpcre3-dev \
	zlib1g-dev \
	libgeoip-dev \
	libxslt1-dev \
	libgd2-dev \
	build-essential \
	libc6 \
	libexpat1 \
	libgd2-xpm-dev \
	libgeoip1 \
	libgeoip-dev \
	libpam0g \
	libssl1.0.0 \
	libxml2 \
	libxslt1.1 \
	zlib1g \
	openssl \
	libssl-dev \
	libgd2-xpm-dev \
	libgeoip-dev \
	libxslt1-dev \
	libpcre++0 \
	libpcre++-dev \
	libperl-dev \
        git-core

RUN ln -s /usr/bin/make /usr/bin/gmake

# Set Vim Config
ADD vimrc /etc/vim/vimrc

# config workdir
WORKDIR /home

# INSTALL LUAJIT
RUN wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
RUN tar zxvf LuaJIT-2.0.4.tar.gz
RUN cd LuaJIT-2.0.4 && make && make install

# set env
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.0
ENV LD_LIBRARY_PATH=/usr/local/lib/:/opt/drizzle/lib/:$LD_LIBRARY_PATH


# INSTALL tengine
WORKDIR /root
ADD https://github.com/alibaba/tengine/archive/${NGINX_VERSION}.tar.gz tengine.tar.gz

RUN tar -zxvf tengine.tar.gz && \
    cd tengine-${NGINX_VERSION} && \
        ./configure \
        --enable-mods-static=all \
        --user=www-data \
        --group=www-data \
        --conf-path=/etc/nginx/nginx.conf \
        --lock-path=/var/lock/nginx.lock \
        --pid-path=/run/nginx.pid \
        --http-client-body-temp-path=/var/lib/nginx/body \
        --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
        --http-proxy-temp-path=/var/lib/nginx/proxy \
        --http-scgi-temp-path=/var/lib/nginx/scgi \
        --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_gunzip_module \
        --with-md5=/usr/include/openssl \
        --with-sha1-asm \
        --with-md5-asm \
        --with-http_auth_request_module \
        --with-http_image_filter_module \
        --with-http_addition_module \
        --with-http_dav_module \
        --with-http_realip_module \
        --with-http_spdy_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_xslt_module \
        --with-http_upstream_ip_hash_module=shared \
        --with-http_upstream_least_conn_module=shared \
        --with-http_upstream_session_sticky_module=shared \
        --with-http_map_module=shared \
        --with-http_user_agent_module=shared \
        --with-http_mp4_module \
        --with-http_split_clients_module=shared \
        --with-http_access_module=shared \
        --with-http_user_agent_module=shared \
        --with-http_degradation_module \
        --with-http_upstream_check_module \
        --with-http_upstream_consistent_hash_module \
        --with-ipv6 \
        --with-file-aio \
        --with-mail \
        --with-mail_ssl_module \
        --with-pcre \
        --with-pcre-jit \
        --prefix=/etc/nginx \
        --with-debug \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/sbin/nginx && \
	make && \
    	make install

RUN mkdir /var/cache/nginx && \
    mkdir /var/ngx_pagespeed_cache && \
    mkdir /var/log/pagespeed && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /etc/nginx/sites-available && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /var/lib/nginx/body && \
    chown -R www-data:www-data /var/cache/nginx && \
    chown -R www-data:www-data /var/ngx_pagespeed_cache && \
    chown -R www-data:www-data /var/log/nginx && \
    chown -R www-data:www-data /var/log/pagespeed && \
    chown -R www-data:www-data /etc/nginx/sites-available && \
    chown -R www-data:www-data /etc/nginx/sites-enabled && \
    chown -R www-data:www-data /var/lib/nginx/body && \
    apt-get -y remove build-essential && \
    dpkg --get-selections | awk '{print $1}'|cut -d: -f1|grep -- '-dev$' | xargs apt-get remove -y && \
    rm -rf /usr/src && \
    rm -rf /tmp/*


# install sshd
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd 
# to get access mount with -v authorized_keys from the host system

# install supervisord
RUN apt-get install -y supervisor

# clear aptlist & home/files
RUN apt-get clean all && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /home/*

RUN apt-get autoremove -y

ADD configs /configs

RUN ln -sf /configs/nginx/nginx.conf /etc/nginx/nginx.conf

RUN ln -sf /configs/supervisor/supervisord.conf /etc/supervisor/
RUN ln -sf /configs/supervisor/conf.d/apps.conf /etc/supervisor/conf.d/apps.conf
RUN ln -sf /configs/php5/php.ini /etc/php5/fpm/php.ini
RUN ln -sf /configs/php5/php-fpm.conf /etc/php5/fpm/php-fpm.conf
RUN ln -sf /configs/php5/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf

RUN cp /configs/php5/imap.ini /etc/php5/mods-available/imap.ini

RUN php5enmod mcrypt imap 


RUN mkdir /var/www

# install a site
ADD configs/www /var/www

WORKDIR /var/www

RUN wget https://github.com/qq215672398/StuGradeWithLaravel5/archive/master.zip

RUN unzip master.zip&&rm -f master.zip

RUN mv StuGradeWithLaravel5-master laravel5

RUN chown -R www-data:www-data /var/www

RUN curl -sS https://getcomposer.org/installer | php

RUN /usr/bin/php composer.phar --version

RUN mv composer.phar /usr/local/bin/composer

ADD .env.example /var/www/laraver5/.env.example

RUN sed -e 's/http:\/\/localhost\/StuGradeWithLaravel5\/public/http:\/\/172.17.0.3\/laravel5\/public/g' /var/www/laravel5/config/app.php 

RUN cd /var/www/laravel5&&composer update

RUN npm install

RUN cd /var/www/laravel5&&composer dump-autoload

RUN cd /var/www/laravel5&&php artisan serve &

EXPOSE 22 80 443 8000

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

