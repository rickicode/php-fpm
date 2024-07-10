FROM php:8.2-fpm

# Maintainer
LABEL maintainer="rickicode@gmail.com"

# Install dependencies
RUN apt-get update && apt-get install -y \
    autoconf g++ make memcached libmemcached-dev zlib1g-dev libssl-dev libicu-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    zip iputils-ping \
    unzip nano dnsutils \
    git default-mysql-client \
    libpq-dev

    
RUN docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && docker-php-ext-install exif \
    && docker-php-ext-install sockets \
    && docker-php-ext-install opcache \
    && docker-php-ext-install bcmath \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install shmop \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install grpc \
    && docker-php-ext-install opcache \
    && docker-php-ext-install inotify \
    && docker-php-ext-install apcu \
    && docker-php-ext-install snmp \
    && docker-php-ext-install sodium
    

# Copy custom PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Copy custom PHP-FPM configuration to run as root
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Expose port 9000 and start PHP-FPM server
EXPOSE 9000
CMD ["php-fpm"]
