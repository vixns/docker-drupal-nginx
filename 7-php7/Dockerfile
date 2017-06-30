FROM vixns/php-nginx:7
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>
WORKDIR /data/htdocs

COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.56
ENV DRUPAL_MD5 5d198f40f0f1cbf9cdf1bf3de842e534

RUN apt-get update \
  && apt-get install --no-install-recommends -y ssmtp libmysqlclient-dev mysql-client \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install pdo_mysql \
  && php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > /usr/local/bin/drush \
  && chmod 755 /usr/local/bin/drush \
  && curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data sites
