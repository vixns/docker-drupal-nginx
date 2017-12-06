FROM vixns/php-nginx:7
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>
WORKDIR /data/htdocs

COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 8.3.4
ENV DRUPAL_MD5 243a2e10032abaf55c10a96555315727

ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN apt-get update \
  && apt-get install -t jessie-backports --no-install-recommends -y ssmtp libmysqlclient-dev libgmp-dev libsodium-dev mysql-client \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
  && docker-php-ext-install pdo_mysql bcmath gmp \
  && php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > /usr/local/bin/drush \
  && chmod 755 /usr/local/bin/drush \
  && git clone https://github.com/Jan-E/uploadprogress.git \
  && pecl install uploadprogress/package.xml \
  && echo "extension=uploadprogress.so" >> "/usr/local/etc/php/conf.d/ext-uploadprogress.ini" \
  && rm -rf uploadprogress \
  && pecl install libsodium \
  && echo "extension=sodium.so" > /usr/local/etc/php/conf.d/sodium.ini \
  && pecl install apcu \
  && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
  && curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data .
