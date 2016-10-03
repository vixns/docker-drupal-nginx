FROM vixns/php-nginx:7
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>
WORKDIR /data/htdocs

COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 8.1.10
ENV DRUPAL_MD5 ce373a1a7a075ff9035b1c95f54170a4

RUN apt-get update \
  && apt-get install -t jessie-backports --no-install-recommends -y ssmtp libmysqlclient-dev mysql-client \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install pdo_mysql \
  && php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > /usr/local/bin/drush \
  && chmod 755 /usr/local/bin/drush \
  && git clone https://github.com/Jan-E/uploadprogress.git \
  && pecl install uploadprogress/package.xml \
  && echo "extension=uploadprogress.so" >> "/usr/local/etc/php/conf.d/ext-uploadprogress.ini" \
  && rm -rf uploadprogress \
  && curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data sites modules themes
