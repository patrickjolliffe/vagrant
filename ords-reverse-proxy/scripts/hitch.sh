#!/bin/bash
yum install -y hitch

cat > /etc/systemd/system/hitch@.service << EOF
[Unit]
Description=Network proxy that terminates TLS/SSL connections - Worker Instance %i
After=syslog.target network.target

[Service]
PIDFile=/run/hitch@%i.pid
ExecStart=/usr/sbin/hitch --config=/etc/hitch/hitch.conf      \\
                          -p /run/hitch@%i.pid                \\
                          -f [*]:42%i0                        \\
                          -b [orp]:41%i0

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
pem-file = "/usr/local/ssl/orp.pem"
EOF

systemctl daemon-reload

systemctl enable hitch\@1.service
systemctl enable hitch\@2.service
systemctl enable hitch\@3.service
#Seem some issues starting hitch services
#Try sleep..
systemctl start hitch\@1.service
sleep 2
systemctl start hitch\@2.service
sleep 2
systemctl start hitch\@3.service