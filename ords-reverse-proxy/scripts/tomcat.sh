#!/bin/bash
#tomcat-native part of EPEL
yum install -y tomcat tomcat-webapps tomcat-native
sed -i 's/port="8080"/port="1111"/g' /etc/tomcat/server.xml
sed -i 's/port="8443"/port="1211"/g' /etc/tomcat/server.xml
sed -i -e "/<Service name=\"Catalina\">/r /vagrant/scripts/https.xml" /etc/tomcat/server.xml   
/usr/bin/systemctl enable tomcat.service
/usr/bin/systemctl start tomcat.service

