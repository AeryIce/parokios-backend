# ====== Build dependencies (composer) ======
FROM composer:2 AS vendor
WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

COPY . .
RUN composer dump-autoload --optimize

# ====== Runtime ======
FROM php:8.3-cli-alpine
WORKDIR /app

# PHP extensions for Laravel + Postgres
RUN apk add --no-cache bash icu-dev oniguruma-dev libzip-dev zip unzip $PHPIZE_DEPS \
    && docker-php-ext-install intl pdo pdo_pgsql zip \
    && apk del $PHPIZE_DEPS

COPY --from=vendor /app /app

ENV APP_ENV=production \
    APP_DEBUG=false

EXPOSE 8000

# Railway ngasih port dinamis via $PORT, jadi kita bind ke situ
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
