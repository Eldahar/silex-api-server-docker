FROM ehekatl/docker-nginx-http2

RUN apt-get update 
RUN apt-get install apt-transport-https lsb-release ca-certificates -y
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg 
RUN echo "deb https://packages.sury.org/php/ jessie main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update 
RUN apt-get install -y openssl
RUN apt-get install php7.1 php7.1-fpm vim git supervisor -y
RUN wget -O /usr/bin/composer https://getcomposer.org/composer.phar && \
    chmod a+x /usr/bin/composer

RUN mkdir /etc/nginx/ssl && \
    openssl req -subj '/CN=*/' -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

RUN mkdir /root/.ssh && \
    chmod 600 /root/.ssh
COPY id_rsa /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa 
RUN mkdir -p /srv && \
    git clone https://github.com/Eldahar/silex-api-1.git /srv/silex-api-1 && \
    composer install -d /srv/silex-api-1 && \
    git clone https://github.com/Eldahar/silex-api-2.git /srv/silex-api-2 && \
    composer install -d /srv/silex-api-2 && \
    git clone https://github.com/Eldahar/silex-api-3.git /srv/silex-api-3 && \
    composer install -d /srv/silex-api-3 && \
    chown www-data:www-data /srv/ -R

RUN rm /etc/php/7.1/fpm/pool.d/*

COPY etc/vim/vimrc /etc/vim/vimrc
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/php/7.1/fpm/pool.d/first.conf /etc/php/7.1/fpm/pool.d/first.conf
COPY etc/php/7.1/fpm/pool.d/second.conf /etc/php/7.1/fpm/pool.d/second.conf
COPY etc/php/7.1/fpm/pool.d/third.conf /etc/php/7.1/fpm/pool.d/third.conf
COPY etc/php/7.1/fpm/php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf
COPY etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf 
COPY etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 443

CMD ["/usr/bin/supervisord"]
