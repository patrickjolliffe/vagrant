# Oracle 18c XE with ORDS and Reverse Proxies

A Vagrant that demonstrates how to configure caching reverse proxies in front of Oracle ORDS

## Required Software

* [Vagrant](https://www.vagrantup.com/downloads.html)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Oracle Database 18c XE](https://www.oracle.com/database/technologies/appdev/xe.html)
* [Oracle REST Data Services (ORDS)](https://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html) 

Place the Oracle Express Edition (XE) RPM and ORDS software in the "software" directory before calling the `vagrant up` command.

Directory contents when software is included.

```
$ tree
.
+--- README.md
+--- Vagrantfile
+--- software
|   +--- oracle-database-xe-18c-1.0-1.x86_64.rpm
|   +--- ords-19.1.0.092.1545.zip
|   +--- ords-19.2.0.199.1647.zip
|   +--- put_software_here.txt
+--- scripts
|   +--- database.sh
|   +--- general.sh
|   +--- httpd.sh
|   +--- hitch.sh
|   +--- nginx.sh
|   +--- ords.sh
|   +--- siege.sh
|   +--- tomcat.sh
|   +--- tls.sh
|   +--- varnish.sh
+--- testsuite
|   +--- orp-auto-manual
|   +--- orp-connections
|   +--- orp-combos
|   +--- orp-demo
|   +--- orp-lib
|   +--- orp-protocols
|   +--- orp-reset
|   +--- orp-threads
|   +--- orp-urls.py
|   +--- orp-warmup
```
