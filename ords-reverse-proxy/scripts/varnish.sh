#!/bin/bash
yum install -y pygpgme yum-utils

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
yum install -y varnish varnish-devel varnish-libs-devel git automake libtool
git clone https://github.com/nigoroll/varnish-modules.git
cd varnish-modules
./bootstrap
./configure
make
cp /home/vagrant/varnish-modules/src/.libs/libvmod_bodyaccess.so /usr/lib64/varnish/vmods/

cat > /etc/varnish/default.vcl << EOF
vcl 4.0;
import bodyaccess;
import std;

backend default {
    .host = "ords";
    .port = "1110";
}

sub vcl_recv {
    unset req.http.X-Body-Len;
   // No Cache
   if (std.port(server.ip) == 4110) {
      return (pass);
   }
   // Cache GETs
   elsif (std.port(server.ip) == 4120) {
      return (hash);
   }
   // Cache POSTs
   elsif (std.port(server.ip) == 4130) {
      if (req.method == "POST") {
         std.cache_req_body(500KB);
         set req.http.X-Body-Len = bodyaccess.len_req_body();
         if (req.http.X-Body-Len == "-1") {
            return(synth(400, "The request body size exceeds the limit"));
         }
         return (hash);
      }
   }
}

sub vcl_hash {
   if (req.http.X-Body-Len) {
      bodyaccess.hash_req_body();
   }
   else {
      hash_data("");
   }
}

sub vcl_backend_fetch {
   if (bereq.http.X-Body-Len) {
      set bereq.method = "POST";
   }
}

sub vcl_deliver {
   if (obj.hits > 0) {
      set resp.http.X-Cache = "HIT";
   } else {
      set resp.http.X-Cache = "MISS";
   }
}
EOF

cat > /usr/lib/systemd/system/varnish.service << EOF
[Unit]
Description=Varnish Cache, a high-performance HTTP accelerator
After=network-online.target

[Service]
Type=forking
KillMode=process

# Maximum number of open files (for ulimit -n)
LimitNOFILE=131072

# Locked shared memory - should suffice to lock the shared memory log
# (varnishd -l argument)
# Default log size is 80MB vsl + 1M vsm + header -> 82MB
# unit is bytes
LimitMEMLOCK=85983232

# Enable this to avoid "fork failed" on reload.
TasksMax=infinity

# Maximum size of the corefile.
LimitCORE=infinity

ExecStart=/usr/sbin/varnishd -a :4110 -a :4120 -a :4130 -f /etc/varnish/default.vcl -s malloc,256m
ExecReload=/usr/sbin/varnishreload

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable varnish.service
systemctl start varnish.service

