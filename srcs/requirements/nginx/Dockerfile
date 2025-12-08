#OS
FROM debian:bookworm

#commands to run to configure the base of the container
RUN apt update -y
RUN apt upgrade -y
RUN apt install nginx -y
RUN apt install vim -y

#TLS/SSL
RUN mkdir -p /etc/nginx/ssl
RUN apt install openssl -y
    #generate SSL certificate
RUN openssl req -x509 -nodes \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=dahmane.42.fr/UID=dahmane"

#config files
RUN mkdir -p /var/run/nginx
    #copy our conf file inside the docker image
COPY /conf/nginx.conf /etc/nginx/nginx.conf
    # add rights
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

#keeps Nginx running so the container stays alive
CMD ["nginx", "-g", "daemon off;"]
