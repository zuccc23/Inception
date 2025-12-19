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
    #delete useless stuff
RUN rm -rf /var/lib/apt/lists/*
    #generate SSL certificate
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -out /etc/nginx/ssl/bundle.crt \
    -keyout /etc/nginx/ssl/private.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=dahmane.42.fr/UID=dahmane"

#config files
    #copy our conf file inside the docker image
COPY /conf/default.conf /etc/nginx/sites-available/default
    #creates a symbolic link to enable our custom config file
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
    #remove defaults index file
RUN rm -rf /var/www/html/index.nginx-debian.html

#makes port 443 accessible
EXPOSE 443

#keeps Nginx running so the container stays alive (=daemon off)
CMD ["nginx", "-g", "daemon off;"]
