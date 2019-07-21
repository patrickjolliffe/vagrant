#!/bin/bash
yum install -y hitch

cat > /etc/systemd/system/hitch@.service << EOF
[Unit]
Description=Network proxy that terminates TLS/SSL connections - Worker Instance %i
After=syslog.target network.target

[Service]
PIDFile=/run/hitch@%i.pid
ExecStart=/usr/sbin/hitch --config=/etc/hitch/hitch.conf \
                          -p /run/hitch@%i.pid           \
                          -f [*]:42%i0                   \
                          -b [127.0.0.1]:41%i0

LimitCORE=infinity
RuntimeDirectory=hitch
Type=simple
PrivateTmp=true
ExecReload=/usr/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/hitch/hitch.conf << EOF
daemon   = on
user     = hitch
group    = hitch
pem-file = "/usr/local/ssl/ords-reverseproxy.pem"
EOF

systemctl daemon-reload
systemctl start hitch@1.service
systemctl start hitch@2.service
systemctl start hitch@3.service

