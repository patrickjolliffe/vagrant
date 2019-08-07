#!/bin/bash
hostnamectl set-hostname ords
echo 127.0.0.1   ords >> /etc/hosts

# fix locale warning
yum reinstall -y glibc-common
cat >> /etc/environment << EOF
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release-latest-7.noarch.rpm
rm epel-release-latest-7.noarch.rpm
yum install -y htop jq mlocate strace

sed -i 's/PATH=/ i ' /home/vagrant/.bash_profile
sed -i '/PATH=/ s/$/:$HOME\/testsuite/' /home/vagrant/.bash_profile

cat >> .bash_profile << EOF
printf '\e[?1000l'         #Try to fix mouse getting screwy in iterm2
echo "Welcome to the ORDS Reverse Proxy Vagrant Machine"
echo "ords-demo will run the test suite"
EOF