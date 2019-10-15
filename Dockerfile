# base image for wordpress. Openresty+PHP
FROM ubuntu:18.04
# versions from most relevant packages and distributions
ARG PHPFPMVERSION="1:7.2+60ubuntu1"
ARG OPENRESTYVERSION="1.15.8.1-1~bionic1"
ARG WPVERSION="5.2.3"
ENV PHPFPMVERSION=$PHPFPMVERSION
ENV OPENRESTYVERSION=$OPENRESTYVERSION
ENV WPVERSION=$WPVERSION

RUN apt-get update && \
		apt-get install --no-install-recommends --no-install-suggests -y \
		supervisor=3.3.1-1.1 \
		php-fpm=$PHPFPMVERSION \
    php-mysqli \
    php-redis \
    php-bcmath \
    php-exif \
    php-gd \
    php-opcache \
    php-zip \
    php-xdebug \
    php-xml \
    php-curl \
    rsync \
    unzip \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    wget \
    ca-certificates && \
    wget -qO /tmp/pubkey.gpg https://openresty.org/package/pubkey.gpg &&\
    DEBIAN_FRONTEND=noninteractive apt-key add /tmp/pubkey.gpg &&\
    DEBIAN_FRONTEND=noninteractive add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" &&\
    apt-get -y update && \
    apt-get -y upgrade &&\
		apt-get -y install openresty=$OPENRESTYVERSION &&\
		apt-get clean && \
    apt-get remove -y --purge \
        gnupg2 \
        lsb-release \
        software-properties-common \
        wget &&\
    rm /tmp/pubkey.gpg &&\
		apt-get clean && \
		rm -rf /var/lib/apt/lists/*

# download wordpress code
WORKDIR /opt/jjlazo79
RUN curl -O https://wordpress.org/wordpress-${WPVERSION}.zip \
    && unzip wordpress-$WPVERSION.zip \
    && rm wordpress-$WPVERSION.zip

# supervisor configuration
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# openresty configuration
RUN mkdir -p /var/log/openresty \
		&& rm /usr/local/openresty/nginx/conf/nginx.conf \
    && chown -R www-data:www-data /var/log/openresty
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# own php-fpm & modules configuration
RUN mkdir -p /var/run/php && \
		mkdir -p /var/log/php-fpm
COPY phpconf.ini /etc/php/7.2/fpm/conf.d/20-phpconf.ini

# copy wordpress core
WORKDIR /var/www/html
RUN rsync -av --progress /opt/jjlazo79/wordpress/ . \
			--exclude wp-content/themes/twenty* \
			--exclude wp-content/plugins/hello.php \
      --exclude wp-content/plugins/akismet* \
      && rm -rf /opt/jjlazo79/

# copy own code, like plugins or themes.
WORKDIR /var/www/html/wp-content
COPY ./themes ./themes
COPY ./plugins ./plugins
RUN mkdir uploads && mkdir upgrades

# download and extract external plugins
WORKDIR /var/www/html/wp-content/plugins
RUN chmod 755 process-plugins.sh
RUN ./process-plugins.sh /var/www/html/wp-content/plugins
RUN rm process-plugins.sh

# setup permissions to folder and files
WORKDIR /var/www/html
RUN chown -R www-data:www-data .
RUN find . -type d -exec chmod 755 {} \;
RUN find . -type f -exec chmod 644 {} \;

WORKDIR /var/www/html

CMD ["supervisord"]
