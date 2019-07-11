#!/bin/bash

export ORDS_HOME="/opt/oracle/ords"
export ORDS_CONF="$ORDS_HOME/config"
export ORDS_PARAMS=${ORDS_HOME}/params/ords_params.properties
export ORACLE_HOME="/opt/oracle/product/18c/dbhomeXE"

mkdir $ORDS_HOME
mkdir $ORDS_CONF

cd $ORDS_HOME
ORDS_INSTALL=`ls /vagrant/software/ords[_-]1*.*.zip |tail -1`
unzip -o $ORDS_INSTALL

su -l oracle -c "$ORACLE_HOME/jdk/bin/java -jar $ORDS_HOME/ords.war configdir $ORDS_HOME/config"

cat > $ORDS_PARAMS <<EOF
db.hostname=localhost
db.port=1521
db.servicename=XEPDB1
db.username=APEX_PUBLIC_USER
db.password=Password123!
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=USERS
schema.tablespace.temp=TEMP
standalone.mode=false
user.apex.listener.password=Password123!
user.apex.restpublic.password=Password123!
user.public.password=Password123!
user.tablespace.default=USERS
user.tablespace.temp=TEMP
sys.user=SYS
sys.password=Password123!
EOF

chown -R oracle:oinstall $ORDS_HOME


echo "******************************************************************************"
echo "Configure ORDS. Safe to run on DB with existing config." `date`
echo "******************************************************************************"
cd ${ORDS_HOME}
java -jar ords.war configdir ${ORDS_CONF}
java -jar ords.war
cp ords.war /usr/share/tomcat/webapps

GRANT inherit privileges ON USER SYSTEM TO ORDS_METADATA;

BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'HR',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'hr',
      p_auto_rest_auth      => FALSE);
END;
/
BEGIN
 ORDS.ENABLE_OBJECT(
   p_enabled => TRUE,
   p_schema => 'HR',
   p_object => 'EMPLOYEES',
   p_object_type => 'TABLE',
   p_object_alias => 'employees',
   p_auto_rest_auth => FALSE);
END;
/
AUDIT SESSION;
alter user hr account unlock