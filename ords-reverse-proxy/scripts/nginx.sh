#!/bin/bash
yum install -y nginx

cat > /etc/nginx/nginx.conf <<EOF
events {
}

http {
   # Reverse Proxy
   server {
      listen 3110;
      location / {
         proxy_pass http://localhost:1110/;
      }
   }
   add_header X-Proxy-Cache \$upstream_cache_status;
   proxy_cache_path /var/cache/nginx
                    keys_zone=ORDS-CACHE:128m;

   # Reverse Proxy + Cache GETs
   server {
      listen 3120;
      location / {
         proxy_pass        http://localhost:1110/;
         proxy_cache       ORDS-CACHE;
         proxy_cache_valid 60m;
      }
   }

    # Reverse Proxy + Cache POSTs
   server {
      listen 3130;
      location / {
         proxy_pass           http://localhost:1110/;
         proxy_cache          ORDS-CACHE;
         proxy_cache_valid    60m;
         proxy_cache_methods  POST;
         proxy_cache_key      "\$uri|\$request_body";
      }
   }

   # Reverse Proxy + TLS
   server {
      listen              3210 ssl;
      server_name         ords-reverseproxy.localdomain;
      ssl_certificate     /usr/local/ssl/ords-reverseproxy.crt;
      ssl_certificate_key /usr/local/ssl/ords-reverseproxy.key;
      location / {
         proxy_pass http://localhost:1110/;
      }
   }

   # Reverse Proxy + TLS + Cache GETs
   server {
      listen              3220 ssl;
      server_name         ords-reverseproxy.localdomain;
      ssl_certificate     /usr/local/ssl/ords-reverseproxy.crt;
      ssl_certificate_key /usr/local/ssl/ords-reverseproxy.key;
      location / {
         proxy_pass        http://localhost:1110/;
         proxy_cache       ORDS-CACHE;
         proxy_cache_valid 60m;
      }
   }

   # Reverse Proxy + TLS + Cache POSTs
   server {
      listen              3230 ssl;
      server_name         ords-reverseproxy.localdomain;
      ssl_certificate     /usr/local/ssl/ords-reverseproxy.crt;
      ssl_certificate_key /usr/local/ssl/ords-reverseproxy.key;
      location / {
         proxy_pass           http://localhost:1110/;
         proxy_cache          ORDS-CACHE;
         proxy_cache_valid    60m;
         proxy_cache_methods  POST;
         proxy_cache_key      "$uri|$request_body";
      }
   }
}
EOF

systemctl enable nginx.service
systemctl start nginx.service
