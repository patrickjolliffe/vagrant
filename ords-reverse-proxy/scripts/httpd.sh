#/bin/bash
yum install -y httpd
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.original
cp /vagrant/scripts/httpd.conf /etc/httpd/conf/httpd.conf
service httpd start