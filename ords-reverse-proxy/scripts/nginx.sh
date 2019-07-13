#!/bin/bash
yum install -y nginx
cp /etc/nginx/nginx.conf /etc/nginx/nginx.backup
cp /vagrant/scripts/nginx.conf /etc/nginx/nginx.conf
systemctl start nginx.service
