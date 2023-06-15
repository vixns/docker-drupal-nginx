FROM vixns/php-nginx:7.4.33
WORKDIR /data/htdocs

COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.98
ENV DRUPAL_MD5 4139f0feecb44a53645242194809b73a

RUN apt-get update \
  && apt-get install --no-install-recommends -y default-libmysqlclient-dev default-mysql-client git \
  libicu-dev libmcrypt-dev libzip-dev libonig-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install pdo_mysql sockets intl zip mbstring  \
  && pecl install mcrypt \
  && docker-php-ext-enable mcrypt \
  && curl -sL https://github.com/drush-ops/drush/releases/download/8.4.11/drush.phar -o /usr/local/bin/drush \
  && chmod 755 /usr/local/bin/drush \
  && curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data sites
