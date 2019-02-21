FROM vixns/php-nginx:7.1

WORKDIR /data/htdocs

ARG APP_ENV=prod

COPY nginx.conf /etc/nginx/conf.d/default.conf

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 8.6.10
ENV DRUPAL_MD5 5aee2dacfb525f146fc28b4535066d1c
ENV TINI_VERSION=v0.18.0 TINI_SUBREAPER=1

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64 /tini
ENTRYPOINT ["/tini", "--"]
CMD ["/sbin/runit-wrapper"]

RUN apk add --no-cache git php7.1-sodium php7.1-apcu \
php7.1-pdo_mysql php7.1-mysqlnd php7.1-mysqli mysql-client \
php7.1-pdo_pgsql php7.1-pgsql postgresql-client php7.1-gd \
&& apk add --no-cache --virtual .build-deps php7.1-dev git gcc g++ linux-headers make \
&& git clone https://github.com/Jan-E/uploadprogress.git \
&& cd uploadprogress \
&& phpize && ./configure && make && make install \
&& apk del --no-cache --purge .build-deps \
&& cd .. && rm -rf uploadprogress \
&& echo "extension=uploadprogress.so" >> "/etc/php/7.1/conf.d/uploadprogress.ini" \
&& curl -sfSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
&& tar -xz --strip-components=1 -f drupal.tar.gz \
&& rm drupal.tar.gz \
&& chown -R www-data:www-data . \
&& apk add --no-cache php7.1-composer \
&& composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative \
&& composer require --no-progress --no-interaction --update-no-dev --update-with-dependencies \
drush/drush drupal/mmeu drupal/health_check drupal/raven drupal/raven_release drupal/swiftmailer drush/config-extra drupal/mailsystem \
&& if [ ${APP_ENV} = "prod" ];then  COMPOSER_DISCARD_CHANGES=1 composer install --no-dev --no-progress --no-interaction; fi \
&& composer clear-cache \
&& ln -s /data/htdocs/vendor/bin/drush /usr/bin/drush \
&& chmod +x /tini
