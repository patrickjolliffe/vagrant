#/bin/bash
yum install -y httpd mod_ssl
cat > /etc/httpd/conf/httpd.conf << EOF
Include conf.modules.d/*.conf

User apache
Group apache

<IfModule mime_module>
    TypesConfig /etc/mime.types
</IfModule>

#Add Cache status to HTTP Header
#Useful for debugging
CacheDetailHeader on

#HTTP Reverse Proxy
Listen 2110
<VirtualHost *:2110>
    ProxyPass        / http://ords:1110/
    ProxyPassReverse / http://ords:1110/
</VirtualHost>

# HTTP Reverse Proxy + Cache GETs
Listen 2120
<VirtualHost *:2120>
    ProxyPass        / http://ords:1110/
    ProxyPassReverse / http://ords:1110/
    CacheEnable      disk /
    CacheRoot        /var/cache/httpd/
</VirtualHost>

LoadModule ssl_module modules/mod_ssl.so

# TLS Reverse Proxy
Listen 2210 https
<VirtualHost *:2210>
    SSLEngine on
    SSLCertificateFile    /usr/local/ssl/ords.crt
    SSLCertificateKeyFile /usr/local/ssl/ords.key
    ProxyPass             / http://ords:1110/
    ProxyPassReverse      / http://ords:1110/
</VirtualHost>

# TLS Reverse Proxy + Cache GETs
Listen 2220 https
<VirtualHost *:2220>
    SSLEngine on
    SSLCertificateFile    /usr/local/ssl/ords.crt
    SSLCertificateKeyFile /usr/local/ssl/ords.key
    ProxyPass             / http://ords:1110/
    ProxyPassReverse      / http://ords:1110/
    CacheEnable           disk  /
    CacheRoot             /var/cache/httpd/
</VirtualHost>
EOF

service httpd start