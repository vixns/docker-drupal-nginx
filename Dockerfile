FROM vixns/php-nginx:8.1.14
WORKDIR /data/htdocs
USER root
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 9.5.3
ENV DRUPAL_MD5 0b4d6e690d1d97b8e32d312a67e6b1ce

RUN apt-get update \
  && apt install -t bullseye-backports --no-install-recommends -y git sudo unzip default-mysql-client default-libmysqlclient-dev libgmp-dev libsodium-dev libzip-dev \
  libcurl3-gnutls libcurl4-gnutls-dev \
  && rm -rf /var/lib/apt/lists/* \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && docker-php-ext-install pdo_mysql bcmath gmp zip exif \
  && git clone https://github.com/Jan-E/uploadprogress.git -b php8 \
  && pecl install uploadprogress/package.xml \
  && echo "extension=uploadprogress.so" >> "/usr/local/etc/php/conf.d/ext-uploadprogress.ini" \
  && rm -rf uploadprogress \
  && pecl install apcu \
  && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
  && curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && dpkg --purge libcurl4-gnutls-dev \
  && apt -y autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && php -d memory_limit=20G /usr/local/bin/composer require drush/drush \
  && curl -sLo /usr/local/bin/drush https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar \
  && chmod 0755 /usr/local/bin/drush \
  && chown -R www-data:www-data /data
USER www-data
