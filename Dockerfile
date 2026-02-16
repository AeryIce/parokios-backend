# ====== Stage 1: Vendor deps (composer) ======
FROM composer:2 AS vendor
WORKDIR /app

# Copy only composer files first for better layer caching
COPY composer.json composer.lock ./

# IMPORTANT: disable scripts because artisan doesn't exist yet
RUN composer install \
  --no-dev \
  --prefer-dist \
  --no-interaction \
  --optimize-autoloader \
  --no-scripts

# Now copy the full application source (including artisan)
COPY . .

# Run package discovery now that artisan exists
RUN php artisan package:discover --ansi

# Optimize autoload
RUN composer dump-autoload --optimize


# ====== Stage 2: Runtime ======
FROM php:8.3-cli-alpine
WORKDIR /app

# PHP extensions needed for Laravel + Postgres
RUN apk add --no-cache bash icu-dev oniguruma-dev libzip-dev zip unzip $PHPIZE_DEPS \
    && docker-php-ext-install intl pdo pdo_pgsql zip \
    && apk del $PHPIZE_DEPS

COPY --from=vendor /app /app

ENV APP_ENV=production \
    APP_DEBUG=false

EXPOSE 8000

# Railway sets $PORT; bind to 0.0.0.0 so it's reachable
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
