FROM debian:bullseye
RUN apt update && apt install -y nginx openssl && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/ssl/certs
RUN mkdir -p /etc/ssl/private
RUN mkdir -p /etc/nginx

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt -subj "/CN=sgluck.42.fr"

COPY conf/nginx.conf /etc/nginx/sites-enabled/default

CMD ["nginx", "-g", "daemon off;"]
EXPOSE 443

