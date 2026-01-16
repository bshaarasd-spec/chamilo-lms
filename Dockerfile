FROM php:7.4-apache

# Install dependencies and extensions required for Chamilo
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    unzip \
    wget \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd intl zip pdo_mysql opcache soap xml mbstring

# Increase PHP limits for Chamilo
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/chamilo.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/chamilo.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/chamilo.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/chamilo.ini \
    && echo "date.timezone = UTC" >> /usr/local/etc/php/conf.d/chamilo.ini

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Download and extract Chamilo
WORKDIR /var/www/html
ENV CHAMILO_VERSION=1.11.32
RUN wget https://github.com/chamilo/chamilo-lms/releases/download/v${CHAMILO_VERSION}/chamilo-${CHAMILO_VERSION}.zip \
    && unzip chamilo-${CHAMILO_VERSION}.zip \
    && mv chamilo-${CHAMILO_VERSION}/* . \
    && rm -rf chamilo-${CHAMILO_VERSION} chamilo-${CHAMILO_VERSION}.zip

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
