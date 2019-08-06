#!/usr/bin/python3
import subprocess
import sys
import os
import argparse
from subprocess import DEVNULL, STDOUT, check_call


protocol_http = 'http'
protocol_https = 'https'

proxy_nginx = 'n'
proxy_varnish = 'v'
proxy_httpd = 'h'
proxy_none = 'o'

method_get = 'g'
method_post = 'p'
all_methods = [method_get,method_post]

def setup(protocol, proxy, method, cache, port):
    print("Protocol:%s Proxy: %s Method: %s" % (protocol, proxy, method))
    if (cache):
        print('Caching')
    else:
        print('Not Caching')

    if ((proxy == proxy_none) and cache):
        print("Invalid testing combo")
        return

    if port is None:
      if proxy == proxy_none:
            port = 1000
        elif proxy == proxy_httpd:
            port = 2000
        elif proxy == proxy_nginx:
            port = 3000
        elif proxy == proxy_varnish:
            port = 4000

        if protocol == protocol_http:
            port += 100
        elif protocol == protocol_https:
            port += 200

        port += 10
        if cache:
            port += 10
       if cache:
            port += 10
            if method == method_post:
                port += 10

    with open('/etc/siege/urls.txt','r+') as f:
        f.seek(0)
        for emp in range(100, 200):
            base_url = '%s://ords-reverseproxy.localdomain:%d/ords/hr/demo/get_employee' % (protocol,port)
            #base_url = '%s://oel7-ords.localdomain:%d/ords/oradb18/hr/employees' % (protocol,port)
            if method == method_post:
                full_url = '%s POST employee_id=%d' % (base_url,emp)
            else:
                full_url = '%s/%d' % (base_url,emp)
            if (emp == 100):
                print(full_url)
            print(full_url, file=f)
        f.truncate()              

parser = argparse.ArgumentParser()
parser.add_argument('-r', '--reverse_proxy', choices=[proxy_none,proxy_httpd,proxy_nginx,proxy_varnish])
cache_parser = parser.add_mutually_exclusive_group(required=False)
cache_parser.add_argument('--cache', action='store_true')
cache_parser.add_argument('--no-cache', action='store_false')
method_parser = parser.add_mutually_exclusive_group(required=False)
method_parser.add_argument('--get',  action='store_true')
method_parser.add_argument('--post', action='store_true')
protocol_parser = parser.add_mutually_exclusive_group(required=False)
protocol_parser.add_argument('--http',  action='store_true')
protocol_parser.add_argument('--https', action='store_true')        
parser.add_argument('--port', type=int)

args = parser.parse_args()
print(args)

if args.cache is None:
    caches = [False, True]
else:
    caches = [args.cache]


if args.reverse_proxy is None:
    proxies = all_proxies
else:
    proxies = [args.reverse_proxy]

if args.http:
    protocols = [protocol_http]
elif args.https:
    protocols = [protocol_https]

if args.post:
    methods= [method_post]
elif args.get:
    methods= [method_get]
