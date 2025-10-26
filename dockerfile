FROM php:8.2-apache

# GD para PNG/JPEG y habilitar rewrite
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install gd \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Copiar la app
COPY . /var/www/html/

# Apache en puerto 8080 (no privilegiado) para poder correr sin root
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
 && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/' /etc/apache2/sites-available/000-default.conf

# Permisos para que Apache (www-data) pueda iniciar sin root
RUN mkdir -p /var/run/apache2 /var/lock/apache2 \
 && chown -R www-data:www-data /var/www/html /var/run/apache2 /var/lock/apache2 /var/log/apache2

# Config PHP opcional
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini

USER www-data
EXPOSE 8080
CMD ["apache2-foreground"]
