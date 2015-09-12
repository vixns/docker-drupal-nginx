FROM vixns/php-nginx:5.6
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>
WORKDIR /data/htdocs

ENV DRUSH_VERSION 6.x

RUN apt-get update && \
  apt-get install --no-install-recommends -y ssmtp libmysqlclient-dev mysql-client && \
  rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql

RUN git clone -b $DRUSH_VERSION https://github.com/drush-ops/drush.git /usr/src/drush && cd /usr/src/drush && ln -s /usr/src/drush/drush /usr/bin/drush && composer install

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.39
ENV DRUPAL_MD5 6f42a7e9c7a1c2c4c9c2f20c81b8e79a

RUN curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data sites
