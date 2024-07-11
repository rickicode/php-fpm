FROM php:8.2-fpm

# Maintainer
LABEL maintainer="rickicode@gmail.com"

# Install dependencies
RUN apt-get update && apt-get install -y \
    autoconf g++ make memcached libmemcached-dev zlib1g-dev libssl-dev libicu-dev \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev zip iputils-ping \
    unzip nano dnsutils openssl git default-mysql-client libpq-dev libbz2-dev \
    libmcrypt-dev libxslt-dev libsnmp-dev \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached redis \
    && apt-get clean

# Adjust SSL/TLS settings
RUN sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1.0',g' /etc/ssl/openssl.cnf \
    && sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) iconv gd pdo_mysql pdo pdo_pgsql mysqli zip \
    exif sockets opcache bcmath intl shmop bz2 snmp \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Install APCu
RUN mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    && docker-php-ext-install apcu

# Copy custom PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Copy custom PHP-FPM configuration to run as root
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Expose port 9000 and start PHP-FPM server
EXPOSE 9000
CMD ["php-fpm"]
