FROM vixns/php-nginx:7.1-debian
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>
WORKDIR /data/htdocs

COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.69
ENV DRUPAL_MD5 292290a2fb1f5fc919291dc3949cdf7c

RUN apt-get update \
  && apt-get install --no-install-recommends -y default-libmysqlclient-dev default-mysql-client git libjpeg-dev libpng-dev librsvg2-dev xfonts-base xfonts-75dpi libfreetype6-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install pdo_mysql gd \
  && curl -sL https://github.com/drush-ops/drush/releases/download/8.1.16/drush.phar -o /usr/local/bin/drush \
  && chmod 755 /usr/local/bin/drush \
  && curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data sites
