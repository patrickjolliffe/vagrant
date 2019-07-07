#!/bin/bash
yum install -y pygpgme yum-utils
cat > /etc/yum.repos.d/varnishcache_varnish62.repo << EOF
[varnishcache_varnish62]
name=varnishcache_varnish62
baseurl=https://packagecloud.io/varnishcache/varnish62/el/7/$basearch
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
yum install varnish varnish-devel