FROM debian:9.8

ARG PHP_VERSION=7.3.4-1+0~20190412071350.37+stretch~1.gbpabc171
ARG PHP_PEAR_VERSION=1:1.10.8+submodules+notgz-1+0~20190219091011.9+stretch~1.gbp1a209a
ARG LIBZIP_DEV_VERSION=1.5.1-4+0~20190318173229.9+stretch~1.gbp333132
ARG WGET_VERSION=1.18-5+deb9u3
ARG GNUPG_VERSION=2.1.18-8~deb9u4
ARG ZIP_VERSION=3.0-11+b1
ARG APACHE_VERSION=2.4.25-3+deb9u7

RUN apt update

# Install tools required by this Dockerfile
RUN apt install -y wget=$WGET_VERSION gnupg2=$GNUPG_VERSION

# Install web server
RUN apt install -y apache2=$APACHE_VERSION apache2-utils=$APACHE_VERSION

# Update package list for PHP7.3
RUN apt install -y ca-certificates apt-transport-https
RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
RUN echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
RUN apt update

# Install PHP7.3
RUN apt install -y php7.3=$PHP_VERSION libapache2-mod-php7.3=$PHP_VERSION php7.3-mysql=$PHP_VERSION php7.3-cli=$PHP_VERSION php7.3-common=$PHP_VERSION php7.3-json=$PHP_VERSION php7.3-opcache=$PHP_VERSION php7.3-readline=$PHP_VERSION php7.3-curl=$PHP_VERSION php7.3-mbstring=$PHP_VERSION php7.3-xml=$PHP_VERSION php7.3-gd=$PHP_VERSION

# Install PHP extension tools
RUN apt install -y php-pear=$PHP_PEAR_VERSION php7.3-dev=$PHP_VERSION libzip-dev=$LIBZIP_DEV_VERSION

# Install PHP extensions
RUN pecl install zip

WORKDIR /build

# Update the php.ini files to include the zip extension
COPY ./config/php/cli/php.ini /build/
RUN mv /etc/php/7.3/cli/php.ini /etc/php/7.3/cli/php.ini.bak && \
    mv /build/php.ini /etc/php/7.3/cli/php.ini

COPY ./config/php/apache2/php.ini /build/
RUN mv /etc/php/7.3/apache2/php.ini /etc/php/7.3/apache2/php.ini.bak && \
    mv /build/php.ini /etc/php/7.3/apache2/php.ini


# @TODO
# Move Tiki Wiki into /var/www/html
# COPY /build/tiki /var/www/html
# Create the Tiki Wiki /var/www/tmp folder for setup
# RUN mkdir -vp /var/www/tmp
# Set correct ownership and permissions on /var/www/html & /var/www/tmp

# @TODO
# Run Tiki Wiki setup scripts


# Install tools required by Tiki Wiki setup
RUN apt install -y zip=$ZIP_VERSION

# Start Apache and keep the container up and running
EXPOSE 80
CMD /usr/sbin/apache2ctl -D FOREGROUND

