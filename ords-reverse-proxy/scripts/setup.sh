# fix locale warning
yum reinstall -y glibc-common
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release-latest-7.noarch.rpm

yum install -y htop jq mlocate siege strace



wget --ca-certificate=/usr/local/ssl/ords-reverseproxy.crt
     https://ords-reverseproxy.localdomain:1211/ords/hr/employees/100 -qO- | jq

/etc/pki/tls/openssl.cnf