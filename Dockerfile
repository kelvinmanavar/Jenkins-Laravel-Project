FROM php:7.4-apache
WORKDIR /var/www/html
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    openssl
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath xml zip
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY composer.json composer.lock ./
COPY . .
COPY ./public/.htaccess /var/www/html/.htaccess
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

RUN php artisan key:generate
RUN php artisan migrate
RUN a2enmod rewrite
RUN service apache2 restart
EXPOSE 8000
CMD ["apache2-foreground"]
