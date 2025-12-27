#!/bin/sh

domain=${DOMAIN:-"localhost"}
fqdn=${FQDN:-"localhost"}
adminemail=${ADMIN_EMAIL:-"admin%40example.com"}
adminpassword=${ADMIN_PASSWORD:-"admin"}

restAPIPlugin () {
  if [ ! -f /data/plugins/restAPI.jar ]; then
    cp /tmp/plugins/restAPI.jar /data/plugins
  fi
}

setupHeader () {
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

  runCurlGet "http://localhost:9090/setup/setup-datasource-settings.jsp?csrf=$CSRF&next=true&mode=embedded&continue=Continue"

  runCurlGet "http://localhost:9090/setup/setup-profile-settings.jsp"

  runCurlPost "http://localhost:9090/setup/setup-profile-settings.jsp" "csrf=$CSRF&mode=default&continue=Continue"

  runCurlGet "http://localhost:9090/setup/setup-admin-settings.jsp"

  runCurlPost "http://localhost:9090/setup/setup-admin-settings.jsp" "csrf=$CSRF&password=admin&email=$adminemail&newPassword=$adminpassword&newPasswordConfirm=$adminpassword&continue=Continue"

  runCurlGet "http://localhost:9090/setup/setup-finished.jsp"

  restAPIPlugin
}

while true; do
  HTTPCODE=$(curl -o /dev/null -I -s -w "%{http_code}\n" http://localhost:9090/setup/index.jsp)
  if [ "$HTTPCODE" = "200" ]; then
    echo "setup mode"
    runSetup
    break
  elif [ "$HTTPCODE" = "302" ]; then
    echo "running mode"
    break
  fi
  echo "Waiting server..."
  sleep 1
done
