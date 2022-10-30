FROM debian:bullseye-slim
LABEL maintainer="andis.cirulis@whitedigital.eu"

# Some general stuff

RUN apt update \
&& apt -y upgrade \
&& apt -y  --no-install-recommends install wget curl build-essential apt-transport-https software-properties-common tzdata unzip bzip2 git lsb-release ca-certificates \
# Set Europe/Riga timezone
&& ln -fs /usr/share/zoneinfo/Europe/Riga /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# PHP 8.1
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
&& apt update \
&& apt-get install -y  --no-install-recommends php8.1-cli \
    && apt-get install -y   --no-install-recommends php8.1-mbstring php8.1-gd php8.1-bcmath php8.1-zip php8.1-xml php8.1-curl php8.1-intl php8.1-memcached php8.1-imap php8.1-pgsql php8.1-http php8.1-raphf php8.1-redis php8.1-apcu


ADD php-development.ini /etc/php/8.1/cli/php.ini

# Installing composer globally
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php composer-setup.php \
&&  php -r "unlink('composer-setup.php');" \
&& mv composer.phar /usr/local/bin/composer

# Install NodeJs & Yarn
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
&& apt install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
&& apt update && apt install yarn

# Install Symfony binary
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
&&  apt install symfony-cli

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# #Expose http, https, xdebug
EXPOSE 80 443

CMD ["/bin/bash"]
