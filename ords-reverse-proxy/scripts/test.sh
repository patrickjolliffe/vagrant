#!/usr/bin/bash
DURATION=${1:-1M}

build_urls() {
   CACHE_MODE=$1
   METHOD=$2
   PROTOCOL=$3
   PROXY=$4 
   REST=$5
   PORT=$6
   
   if [ -z "$PORT" ]; 
   then
      case $PROXY in
      proxy_none  )
        PORT=1000 ;;
      proxy_httpd )
        PORT=2000 ;;
      proxy_nginx )
        PORT=3000 ;;
      proxy_varnish )
        PORT=4000 ;;
      esac

      case $PROTOCOL in
      http  )
         PORT=$[PORT+100] ;;
      https )
         PORT=$[PORT+200] ;;
      esac

      if [ "$CACHE_MODE" = cache_off ];
      then
         PORT=$[PORT+10] 
      elif [ "$CACHE_MODE" = cache_on ] && [ "$METHOD" = 'GET' ];
      then
        PORT=$[PORT+20] 
      elif [ "$CACHE_MODE" = cache_on ] && [ "$METHOD" = 'POST' ];  
      then
         PORT=$[PORT+30]
      fi
   fi
   > /etc/siege/urls.txt

   URL=$PROTOCOL'://ords-reverseproxy.localdomain:'$PORT'/ords/hr/'   
   if [ "$REST" = rest_manual ];
   then
      URL=$URL"demo/get_employee"
   else
      URL=$URL"employees"
   fi

   for EMP in {100..200}
   do
      if [ "$METHOD" = 'POST' ];
      then
         LINE=$URL' POST employee_id='$EMP
      else
         LINE=$URL'/'$EMP
      fi
      echo $LINE >> /etc/siege/urls.txt          
   done
}

run_siege() { 
   echo -n $1:
   siege -c 255 -t $DURATION 2>&1 | grep rate | cut -f 2
}

tomcat_warmup() {
   echo Demonstate Tomcat 'warm-up'...
   echo Restarting Tomcat...
   sudo systemctl restart tomcat.service
   echo Sleep 10 seconds to allow Tomcat to startup
   sleep 10
   build_urls cache_off GET http proxy_none rest_manual
   echo Run 5*1 minute sieges, should show transaction rate increase as Tomcat warms up
   echo Note also some variation in transaction rate even after it has warmed-up
   for i in {1..5}
   do
      siege -c 255 -t $DURATION 2>&1 | grep rate
   done
}

1_vs_255_connections() {
   echo Demonstate difference between 1 and 255 siege connections...
   echo Compare the values for "Transaction rate" and "Response Time" 
   build_urls cache_off GET http proxy_none rest_manual
   siege -c   1 -t $DURATION >/dev/null
   siege -c 255 -t $DURATION >/dev/null
}

manual_vs_autorest() {
   echo Demonstrate difference between auto and manually generated REST services
   echo Manually generated should exhibit higher transaction rate
   build_urls cache_off GET http proxy_none rest_auto
   run_siege "AutoREST"
   build_urls cache_off GET http proxy_none rest_manual
   run_siege "manually created service"
}

openssl_vs_jre () {
   echo "Demonstrate benefits to running J2EE JRE vs OpenSSL APR (tomcat-native)"
   echo Hopefully OpenSSL APR should perform better
   build_urls cache_off GET https proxy_none rest_manual 1211
   run_siege "J2EE JRE"   
   build_urls cache_off GET https proxy_none rest_manual
   run_siege "OpenSSL APR"   
}

run_all_combos() {
   DURATION=${1}
   echo Run complete test-suite for all combos of:
   echo "Not Caching & Caching"
   echo "Methods: GET & POST"
   echo "Protocols: HTTP & HTTPS"
   echo "Reverse Proxies: none (direct to Tomcat), httpd (Apache HTTP Server), nginx and varnish(&Hitch)"
   echo Skipping impossible combinations 
   for CACHE_MODE in cache_off cache_on
#   for CACHE_MODE in cache_on
   do 
      for METHOD in GET POST
#      for METHOD in POST
      do 
         for PROTOCOL in http https
#         for PROTOCOL in http
         do 
            for PROXY in proxy_none proxy_httpd proxy_nginx proxy_varnish
#            for PROXY in proxy_nginx
            do
               #Skip invalid combos
               if [ "$CACHE_MODE" = "cache_on" ]
               then
                  if [ "$PROXY" = "proxy_none" ]
                  then
                     continue          
                  elif [ "$METHOD" = 'POST' ] && [ "$PROXY" = 'proxy_httpd' ]
                  then
                     continue 
                  fi
               fi
               build_urls $CACHE_MODE $METHOD $PROTOCOL $PROXY rest_manual
               run_siege "$CACHE_MODE,$METHOD,$PROTOCOL,$PROXY"
            done
         done
      done
   done
}
#Allow duration as command line argment, default to one minute
killall -9 siege
tomcat_warmup
1_vs_255_connections
manual_vs_autorest
openssl_vs_jre
run_all_combos

