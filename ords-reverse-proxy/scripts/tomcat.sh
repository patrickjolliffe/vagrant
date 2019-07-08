#!/bin/bash
sudo yum install -y tomcat tomcat-native tomcat-webapps
sudo /usr/bin/systemctl enable tomcat.service
sudo /usr/bin/systemctl start tomcat.service

sudo sed -i 's/port="8080"/port="1111"/g' /etc/tomcat/server.xml