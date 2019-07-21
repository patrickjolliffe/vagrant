# fix locale warning
yum reinstall -y glibc-common
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release-latest-7.noarch.rpm
rm epel-release-latest-7.noarch.rpm

yum install -y htop jq mlocate strace

mkdir /home/vagrant/bin
cat > /home/vagrant/bin/orpdemo << EOF
#!/usr/bin/bash
/vagrant/scripts/test.sh \$1
EOF
chown vagrant:vagrant /home/vagrant/bin/orpdemo
chmod u+x /home/vagrant/bin/orpdemo

hostnamectl set-hostname ords-reverseproxy.localdomain
echo 127.0.0.1   ords-reverseproxy.localdomain >> /etc/hosts