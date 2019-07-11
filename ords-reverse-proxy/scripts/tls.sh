#!/bin/bash
mkdir /usr/local/ssl
cd /usr/local/ssl

openssl req  -nodes \
             -new  \
             -x509 \
             -subj "/C=/ST=/L=/O=/OU=/CN=ords-reverseproxy.localdomain" \
             -keyout ords-reverseproxy.key \
             -out ords-reverseproxy.crt

openssl pkcs12 -export \
               -in ords-reverseproxy.crt  \
               -inkey ords-reverseproxy.key \
               -out ords-reverseproxy.p12 \
               -passout pass:Password123

keytool -importkeystore -srckeystore ords-reverseproxy.p12 \
        -srcstoretype PKCS12 \
        -destkeystore ords-reverseproxy.jks \
        -deststoretype JKS \
        -storepass Password123 \
        -keypass Password123 \
        -srcstorepass Password123
