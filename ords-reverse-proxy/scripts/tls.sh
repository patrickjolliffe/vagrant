#!/bin/bash
#Need java for keytool
yum install -y java
mkdir /usr/local/ssl
cd /usr/local/ssl

openssl req  -nodes \
             -new  \
             -x509 \
             -days 1024 \
             -subj "/CN=ords-reverseproxy.localdomain" \
             -keyout ords-reverseproxy.key \
             -out ords-reverseproxy.crt
             
openssl pkcs12 -export \
               -in ords-reverseproxy.crt  \
               -inkey ords-reverseproxy.key \
               -out ords-reverseproxy.p12 \
               -passout pass:Password123

keytool -importkeystore \
        -srckeystore ords-reverseproxy.p12 \
        -srcstoretype PKCS12 \
        -destkeystore ords-reverseproxy.jks \
        -deststoretype JKS \
        -storepass Password123 \
        -keypass Password123 \
        -srcstorepass Password123

cat /usr/local/ssl/ords-reverseproxy.key > /usr/local/ssl/ords-reverseproxy.pem
cat /usr/local/ssl/ords-reverseproxy.crt >> /usr/local/ssl/ords-reverseproxy.pem

#Configure cert for wget
echo ca_certificate=/usr/local/ssl/ords-reverseproxy.crt >> /etc/wgetrc

