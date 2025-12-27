#!/bin/bash

domain=${DOMAIN:-"localhost"}
fqdn=${FQDN:-"localhost"}
adminemail=${ADMIN_EMAIL:-"admin%40example.com"}
adminpassword=${ADMIN_PASSWORD:-"admin"}
dbtype=${DB_TYPE:-'embedded'}
datasourcemode='embedded'

case "$dbtype" in
  postgres)
    datasourcemode='standard'
    dbpresets=${DB_PRESETS:-"3"}
    dbdriver=${DB_DRIVER:-"org.postgresql.Driver"}
    dbserverurlraw=${DB_SERVER_URL:-"jdbc:postgresql://localhost:5432/openfire"}
    dbserverurl=$(echo -n "$dbserverurlraw" | od -An -tx1 | tr ' ' '\n' | awk 'NF {printf "%%%s", toupper($1)}')
    dbusername=${DB_USERNAME:-"postgres"}
    dbpassword=${DB_PASSWORD:-"mysecurepassword"}
    dbminconnections=${DB_MIN_CONNECTIONS:-"5"}
    dbmaxconnections=${DB_MAX_CONNECTIONS:-"25"}
    dbconnectiontimeout=${DB_CONNECTION_TIMEOUT:-"1.0"}
    ;;
   mysql|oracle|mssql)
    #TODO: implement other DB types
    datasourcemode='standard'
  ;;
  *)
    datasourcemode='embedded'
    ;;
esac

plugins () {
  if [ ! -f /data/plugins/restAPI.jar ]; then
    cp /tmp/plugins/restAPI.jar /data/plugins
  fi
  if [ ! -f /data/plugins/subscription.jar ]; then
    cp /tmp/plugins/subscription.jar /data/plugins
  fi
  if [ ! -f /data/plugins/xmppweb.jar ]; then
    cp /tmp/plugins/xmppweb.jar /data/plugins
  fi
}

setupHeader () {
  CSRF=''
  header=$(curl -Is 'http://localhost:9090/setup/index.jsp')
  JSESSIONID=$(echo "$header" | grep -iE '^Set-Cookie: JSESSIONID=' | sed 's/.*JSESSIONID=\([^;]*\).*/\1/')
}

runCurlGet () {
  url=$1
  header=$(curl -is "${url}" -H "Cookie: JSESSIONID=$JSESSIONID; csrf=$CSRF;")
  CSRF=$(echo "$header" | grep -iE '^Set-Cookie: csrf=' | sed 's/.*csrf=\([^;]*\).*/\1/')
}

runCurlPost () {
  url=$1
  dataRaw=$2
  header=$(curl -is "${url}" -H "Content-Type: application/x-www-form-urlencoded" -H "Cookie: JSESSIONID=$JSESSIONID; csrf=$CSRF;" --data-raw "${dataRaw}")
  CSRF=$(echo "$header" | grep -iE '^Set-Cookie: csrf=' | sed 's/.*csrf=\([^;]*\).*/\1/')
}

runSetup () {
  setupHeader

  runCurlGet "http://localhost:9090/setup/index.jsp?csrf=$CSRF&localeCode=en&save=Continue"

  runCurlGet "http://localhost:9090/setup/setup-host-settings.jsp"

  runCurlPost "http://localhost:9090/setup/setup-host-settings.jsp" "csrf=$CSRF&domain=$domain&fqdn=$fqdn&embeddedPort=9090&securePort=9091&encryptionAlgorithm=Blowfish&encryptionKey=&encryptionKey1=&continue=Continue"

  runCurlGet "http://localhost:9090/setup/setup-datasource-settings.jsp"

  runCurlGet "http://localhost:9090/setup/setup-datasource-settings.jsp?csrf=$CSRF&next=true&mode=$datasourcemode&continue=Continue"

  if [ "$datasourcemode" = 'standard' ]; then
    runCurlGet "http://localhost:9090/setup/setup-datasource-standard.jsp"
    runCurlPost "http://localhost:9090/setup/setup-datasource-standard.jsp" "csrf=${CSRF}&presets=${dbpresets}&driver=${dbdriver}&serverURL=${dbserverurl}&username=${dbusername}&password=${dbpassword}&minConnections=${dbminconnections}&maxConnections=${dbmaxconnections}&connectionTimeout=${dbconnectiontimeout}&continue=Continue"
  fi

  runCurlGet "http://localhost:9090/setup/setup-profile-settings.jsp"

  runCurlPost "http://localhost:9090/setup/setup-profile-settings.jsp" "csrf=$CSRF&mode=default&continue=Continue"

  runCurlGet "http://localhost:9090/setup/setup-admin-settings.jsp"

  runCurlPost "http://localhost:9090/setup/setup-admin-settings.jsp" "csrf=$CSRF&password=admin&email=$adminemail&newPassword=$adminpassword&newPasswordConfirm=$adminpassword&continue=Continue"

  runCurlGet "http://localhost:9090/setup/setup-finished.jsp"

  plugins
}

echo "--- Waiting server..."

while true; do
  HTTPCODE=$(curl -o /dev/null -I -s -w "%{http_code}\n" http://localhost:9090/setup/index.jsp)
  if [ "$HTTPCODE" = "200" ]; then
    echo "--- setup mode"
    runSetup
    echo "--- done setup"
    break
  elif [ "$HTTPCODE" = "302" ]; then
    echo "--- running mode"
    break
  fi
  sleep 1
done
