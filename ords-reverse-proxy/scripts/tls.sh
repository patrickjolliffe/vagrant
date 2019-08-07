#!/bin/bash
#Need java for keytool
yum install -y java
mkdir /usr/local/ssl
cd /usr/local/ssl

openssl req  -nodes          \
             -new            \
             -x509           \
             -days 1024      \
             -subj "/CN=ords" \
             -keyout ords.key \
             -out ords.crt
             
openssl pkcs12 -export                    \
               -in ords.crt               \
               -inkey ords.key            \
               -out ords.p12              \
               -passout pass:Password123

keytool -importkeystore           \
        -srckeystore ords.p12      \
        -srcstoretype PKCS12      \
        -destkeystore ords.jks     \
        -deststoretype JKS        \
        -storepass Password123    \
        -keypass Password123      \
        -srcstorepass Password123

cat /usr/local/ssl/ords.key > /usr/local/ssl/ords.pem
cat /usr/local/ssl/ords.crt >> /usr/local/ssl/ords.pem

#Configure cert for wget
echo ca_certificate=/usr/local/ssl/ords.crt >> /etc/wgetrc

