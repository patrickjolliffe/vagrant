#!/bin/bash
hostnamectl set-hostname ords-reverseproxy.localdomain
echo 127.0.0.1   ords-reverseproxy.localdomain >> /etc/hosts

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
echo "Please type orp-all to run the entire test suite"
echo "An optional duration parameter can be provided, using same format as siege"
echo "For example 10S (seconds) or 2M (minute)."
echo "If this is not provided the default is 1 Minute"
echo "To just compare direct vs reverse proxy use orp-combos"
EOF