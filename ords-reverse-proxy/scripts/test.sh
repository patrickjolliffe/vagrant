#!/usr/bin/bash
run_siege() {
   echo "Sieging $1..."
   siege -c 255 -t 1M 2>&1 | grep rate
}

tomcat_warmup() {
   echo Demonstate Tomcat 'warm-up'...
   echo Restarting Tomcat...
   sudo systemctl restart tomcat.service
   echo Sleep 10 seconds to allow Tomcat to startup
   sleep 10   
   python3 /vagrant/scripts/urls.py --http --get -r none
   echo Run 5*1 minute sieges, hopefully showing transaction rate increase
   echo Note also some variation in transaction rate even after it has 'warmed-up'
   for i in {1..5}
   do
      siege -c 255 -t 1M 2>&1 | grep rate
   done
}

1_vs_255_connections() {
   echo Demonstate difference between 1 and 255 siege connections...
   echo Compare the values for "Transaction rate" and "Response Time" 
   python3 /vagrant/scripts/urls.py --http --get -r none
   echo "Sieging with 1 connection..."
   siege -c 1 -t 1M >/dev/null
   echo "Sieging with 255 connections..."
   siege -c 255 -t 1M >/dev/null
}

manual_vs_autorest() {
   echo Demonstrate difference between auto and manually generated REST services
   echo Should see significantly higher value for manually generated
   python3 /vagrant/scripts/urls.py --http --get -r none --auto
   run_siege "AutoREST"
   python3 /vagrant/scripts/urls.py --http --get -r none
   run_siege "manually created service"
}


openssl_vs_jre () {
   echo "Demonstrate benefits to running J2EE JRE vs OpenSSL APR (tomcat-native)"
   echo Hopefully OpenSSL APR should perform better
   python3 /vagrant/scripts/urls.py --https --port 1211 --get -r none
   run_siege "J2EE JRE"   
   python3 /vagrant/scripts/urls.py --https --port 1210 --get -r none
   run_siege "OpenSSL APR"   
}

run_all_combos() {
   echo Run complete test-suite for all combos of:
   echo "Caching & Not Caching"
   echo "Methods: GET & POST"
   echo "Protocols: HTTP & HTTPS"
   echo "Reverse Proxies: none (direct to Tomcat), httpd (Apache HTTP Server), nginx and varnish(&Hitch)"
   echo Skipping impossible combinations 
   for cache_mode in no_cache cache
   do 
      for method in get post
      do 
         for protocol in http https
         do 
            for proxy in none httpd nginx varnish
            do
               #Skip invalid combos
               if [ "$cache_mode" = 'cache' ]
               then
                  if [ "$proxy" = 'none' ]
                  then
                     continue          
                  elif [ "$method" = 'post' ] && [ "$proxy" = 'httpd' ]
                  then
                     continue 
                  fi
               fi
               python3 /vagrant/scripts/urls.py --$cache_mode --$method --$protocol -r $proxy -v
               run_siege "$cache_mode,method=$method,protocol=$protocol,proxy=$proxy"
            done
         done
      done
   done
}
killall -9 siege
#tomcat_warmup
#1_vs_255_connections
#manual_vs_autorest
#openssl_vs_jre
run_all_combos

