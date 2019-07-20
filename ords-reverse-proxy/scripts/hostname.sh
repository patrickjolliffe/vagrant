#!/bin/bash
hostnamectl set-hostname ords-reverseproxy.localdomain
echo 127.0.0.1   ords-reverseproxy.localdomain >> /etc/hosts