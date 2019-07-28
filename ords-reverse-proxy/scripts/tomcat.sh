#!/bin/bash
#tomcat-native part of EPEL
yum install -y tomcat tomcat-native

cat > /tmp/sed_herefile << EOF
   <!-- HTTP -->

   <!-- APR/native connector -->   
   <Connector port="1110"    protocol="org.apache.coyote.http11.Http11AprProtocol"
              maxThreads="4"
              connectionTimeout="20000" />

   <!-- Non-blocking Java connector -->
   <Connector port="1111" protocol="org.apache.coyote.http11.Http11NioProtocol"
              maxThreads="4"
              connectionTimeout="20000" />

  <!-- Blocking Java connector -->
  <Connector port="1112" protocol="org.apache.coyote.http11.Http11Protocol"
              maxThreads="4"
              connectionTimeout="20000" />

  <!-- Not Implemented in Tomcat 7 :(
  <Connector port="1112" protocol="org.apache.coyote.http11.Http11Nio2Protocol"
              maxThreads="4"
              connectionTimeout="20000" />              
   -->              

   <!-- HTTPS -->
   <!-- APR/Native Connector uses OpenSSL -->
   <Connector  port="1210" protocol="org.apache.coyote.http11.Http11AprProtocol"
               SSLCertificateFile="/usr/local/ssl/orp.crt"
               SSLCertificateKeyFile="/usr/local/ssl/orp.key"
               maxThreads="4" SSLEnabled="true" scheme="https" secure="true"
               clientAuth="false" sslProtocol="TLS" />

   <!-- Non-blocking Java connector uses JSSE SSL  -->
   <Connector port="1211" protocol="org.apache.coyote.http11.Http11NioProtocol"              
              keystoreFile="/usr/local/ssl/orp.jks"
              keystorePass="Password123"
              maxThreads="4" SSLEnabled="true" scheme="https" secure="true"
              clientAuth="false" sslProtocol="TLS" />


   <!-- Non-blocking Java connector uses JSSE SSL  -->
   <Connector port="1212" protocol="org.apache.coyote.http11.Http11Protocol"              
              keystoreFile="/usr/local/ssl/orp.jks"
              keystorePass="Password123"
              maxThreads="4" SSLEnabled="true" scheme="https" secure="true"
              clientAuth="false" sslProtocol="TLS" />
EOF

sed -i '/<Service name="Catalina">/r /tmp/sed_herefile' /etc/tomcat/server.xml

#Skip these changes, they don't seem to improve performance
#echo JAVA_OPTS="-Xms2048m -Xmx2048m -server" >> /etc/tomcat/tomcat.conf
#sed -i "/<Valve className=\"org.apache.catalina.valves.AccessLogValve\" /i\ <\!--" /etc/tomcat/server.xml
echo JAVA_OPTS="-Djava.security.egd=file:/dev/urandom" >> /etc/tomcat/tomcat.conf
/usr/bin/systemctl enable tomcat.service
/usr/bin/systemctl start tomcat.service

#Allow Vagrant user to acccess Tomcat logs
usermod -G tomcat -a vagrant
chown tomcat:tomcat /var/log/tomcat