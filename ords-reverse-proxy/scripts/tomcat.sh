#!/bin/bash
#tomcat-native part of EPEL
yum install -y tomcat tomcat-webapps tomcat-native

#sed -i 's/port="8080"/port="1110"/g' /etc/tomcat/server.xml
#sed -i 's/port="8443"/port="1210"/g' /etc/tomcat/server.xml
#sed -i -e "/<Service name=\"Catalina\">/r /vagrant/scripts/https.xml" /etc/tomcat/server.xml

cat > /tmp/sed_herefile << EOF
   <!-- Tomcat HTTP -->
   <Connector port="1110" protocol="HTTP/1.1"
              connectionTimeout="20000"
              redirectPort="8443" />

   <!-- APR (Native) OpenSSL -->
   <Connector  port="1210" protocol="HTTP/1.1"
               SSLCertificateFile="/usr/local/ssl/ords-reverseproxy.crt"
               SSLCertificateKeyFile="/usr/local/ssl/ords-reverseproxy.key"
               maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
               clientAuth="false" sslProtocol="TLS" />

   <!-- JSSE Java Runtime  -->
   <Connector port="1211" protocol="org.apache.coyote.http11.Http11NioProtocol"
              sslImplementationName="org.apache.tomcat.util.net.jsse.JSSEImplementation"
              keystoreFile="/usr/local/ssl/ords-reverseproxy.jks"
              keystorePass="Password123"
              maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
              clientAuth="false" sslProtocol="TLS" />
EOF
sed '/<Service name="Catalina">/r /tmp/sed_herefile' /etc/tomcat/server.xml

#Skip these changes, they don't seem to improve performance
#echo JAVA_OPTS="-Xms2048m -Xmx2048m -server" >> /etc/tomcat/tomcat.conf
#sed -i "/<Valve className=\"org.apache.catalina.valves.AccessLogValve\" /i\ <\!--" /etc/tomcat/server.xml
#sed -i "/ost>/i\  -->" /etc/tomcat/server.xml
echo JAVA_OPTS="-Djava.security.egd=file:/dev/urandom" >> /etc/tomcat/tomcat.conf
/usr/bin/systemctl enable tomcat.service
/usr/bin/systemctl start tomcat.service

#Allow Vagrant user to acccess Tomcat logs
usermod -G tomcat -a vagrant
chown tomcat:tomcat /var/log/tomcat