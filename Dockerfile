FROM debian:bookworm-slim
LABEL maintainer="andis.cirulis@whitedigital.eu"

# Some general stuff

RUN apt update \
&& apt -y upgrade \
&& apt -y  --no-install-recommends install wget curl build-essential apt-transport-https software-properties-common tzdata unzip bzip2 git lsb-release ca-certificates \
# Set Europe/Riga timezone
&& ln -fs /usr/share/zoneinfo/Europe/Riga /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# PHP 8.2
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
&& apt update \
&& apt-get install -y  --no-install-recommends php8.2-cli \
    && apt-get install -y   --no-install-recommends php8.2-mbstring php8.2-gd php8.2-bcmath php8.2-zip php8.2-xml php8.2-curl php8.2-intl php8.2-memcached php8.2-imap php8.2-pgsql php8.2-http php8.2-raphf php8.2-redis php8.2-apcu


ADD php-development.ini /etc/php/8.2/cli/php.ini

# Installing composer globally
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php composer-setup.php \
&&  php -r "unlink('composer-setup.php');" \
&& mv composer.phar /usr/local/bin/composer

# Install NodeJs & Yarn
ENV NODE_MAJOR=18
RUN mkdir -p /etc/apt/keyrings \
&&  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
&& echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
&& apt update && apt install nodejs -y \
&& corepack enable

# Install Symfony binary
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
&&  apt install symfony-cli

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# #Expose http, https, xdebug
EXPOSE 80 443

CMD ["/bin/bash"]
