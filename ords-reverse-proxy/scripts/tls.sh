#!/bin/bash
#Need java for keytool
yum install -y java
mkdir /usr/local/ssl
cd /usr/local/ssl

openssl req  -nodes          \
             -new            \
             -x509           \
             -days 1024      \
             -subj "/CN=orp" \
             -keyout orp.key \
             -out orp.crt
             
openssl pkcs12 -export                   \
               -in orp.crt               \
               -inkey orp.key            \
               -out orp.p12              \
               -passout pass:Password123

keytool -importkeystore           \
        -srckeystore orp.p12      \
        -srcstoretype PKCS12      \
        -destkeystore orp.jks     \
        -deststoretype JKS        \
        -storepass Password123    \
        -keypass Password123      \
        -srcstorepass Password123

cat /usr/local/ssl/orp.key > /usr/local/ssl/orp.pem
cat /usr/local/ssl/orp.crt >> /usr/local/ssl/orp.pem

#Configure cert for wget
echo ca_certificate=/usr/local/ssl/orp.crt >> /etc/wgetrc

