FROM debian:bookworm

#install PHP-FPM and PHP-MySQL
RUN apt update -y && \
    apt install -y \
    netcat-openbsd \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    curl
    	#-php -php fpm -mysql command -curl

#delete temporary package lists
RUN rm -rf /var/lib/apt/lists/*

#wordpress command line tool
	#downloads wordpress
	#allows to  control wordpress from the terminal
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	#exec rights
RUN chmod +x wp-cli.phar
	#rename
RUN mv wp-cli.phar /usr/local/bin/wp

#make PHP-FPN listen on port 9000 (and not unix socket)
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

#copy config script
COPY ./tools/script.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/script.sh

#run script (safer than CMD cus it cant be overran as easily)
ENTRYPOINT ["/usr/local/bin/script.sh"]