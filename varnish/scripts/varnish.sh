#!/bin/bash
yum update -y
yum install -y epel-release
yum install -y pygpgme yum-utils python36 mlocate python36-docutils python3-sphinx

cat > /etc/yum.repos.d/varnishcache_varnish62.repo << EOF
[varnishcache_varnish62]
name=varnishcache_varnish62
baseurl=https://packagecloud.io/varnishcache/varnish62/el/7/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/varnishcache/varnish62/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[varnishcache_varnish62-source]
name=varnishcache_varnish62-source
baseurl=https://packagecloud.io/varnishcache/varnish62/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/varnishcache/varnish62/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

yum -q makecache -y --disablerepo='*' --enablerepo='varnishcache_varnish62'
yum install -y varnish varnish-devel git automake libtool wget
git clone https://github.com/nigoroll/varnish-modules.git
cd varnish-modules
./bootstrap
./configure
make

cp /root/varnish-modules/src/.libs/libvmod_bodyaccess.so /usr/lib64/varnish/vmods/
