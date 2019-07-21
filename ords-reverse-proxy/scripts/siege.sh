#!/bin/bash
yum install -y siege
#Change permissions to allow vagrant user to overwrite
chown vagrant:vagrant /etc/siege/urls.txt