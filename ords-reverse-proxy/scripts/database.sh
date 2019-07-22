#!/bin/bash
PASSWORD=Password123!
yum install -y oracle-database-preinstall-18c
yum -y localinstall /vagrant/software/oracle-database-xe-18c-1.0-1.x86_64.rpm

cat > /etc/sysconfig/oracle-xe-18c.conf <<EOF
LISTENER_PORT=1521
EM_EXPRESS_PORT=5500
CHARSET=AL32UTF8
DBFILE_DEST=
SKIP_VALIDATIONS=true
ORACLE_PASSWORD=Password123
EOF
chmod g+w /etc/sysconfig/oracle-xe-18c.conf

/etc/init.d/oracle-xe-18c configure
/etc/init.d/oracle-xe-18c start
systemctl daemon-reload
systemctl enable oracle-xe-18c

# set environment variables
cat > /home/oracle/.bashrc <<EOF
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
export ORACLE_SID=XE
export PATH=\$PATH:\$ORACLE_HOME/bin
EOF