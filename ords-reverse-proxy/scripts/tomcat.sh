#!/bin/bash
#tomcat-native part of EPEL
yum install -y tomcat tomcat-webapps tomcat-native
sed -i 's/port="8080"/port="1110"/g' /etc/tomcat/server.xml
sed -i 's/port="8443"/port="1210"/g' /etc/tomcat/server.xml
sed -i -e "/<Service name=\"Catalina\">/r /vagrant/scripts/https.xml" /etc/tomcat/server.xml
#Skip these changes, they don't seem to improve performance
#echo JAVA_OPTS="-Xms2048m -Xmx2048m -server" >> /etc/tomcat/tomcat.conf
#sed -i "/<Valve className=\"org.apache.catalina.valves.AccessLogValve\" /i\ <\!--" /etc/tomcat/server.xml
#sed -i "/ost>/i\  -->" /etc/tomcat/server.xml
/usr/bin/systemctl enable tomcat.service
/usr/bin/systemctl start tomcat.service
usermod -G tomcat -a vagrant
chown tomcat:tomcat /var/log/tomcat