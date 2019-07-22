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

mkdir /home/vagrant/bin
cat > /home/vagrant/bin/orpdemo << EOF
#!/usr/bin/bash
/vagrant/scripts/orpdemo.sh \$1
EOF

chown vagrant:vagrant /home/vagrant/bin/orpdemo
chmod u+x /home/vagrant/bin/orpdemo