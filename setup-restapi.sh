#!/bin/bash

adminpassword=${ADMIN_PASSWORD:-"admin"}
restApiSecret=${REST_API_SECRET:-"myrestapisecret"}

runLogin () {
  header=$(curl -Is 'http://localhost:9090/login.jsp?url=%2Frest-api.jsp')
  CSRF=$(echo "$header" | grep -iE '^Set-Cookie: csrf=' | sed 's/.*csrf=\([^;]*\).*/\1/')
  JSESSIONID=$(echo "$header" | grep -iE '^Set-Cookie: JSESSIONID=' | sed 's/.*JSESSIONID=\([^;]*\).*/\1/')

  header=$(curl -is 'http://localhost:9090/login.jsp' -H 'Content-Type: application/x-www-form-urlencoded' -H "Cookie: JSESSIONID=$JSESSIONID; csrf=$CSRF;" --data-raw "login=true&csrf=$CSRF&username=admin&password=$adminpassword")
  CSRF=$(echo "$header" | grep -iE '^Set-Cookie: csrf=' | sed 's/.*csrf=\([^;]*\).*/\1/')
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

echo "configuring rest api plugin"
runLogin
runCurlGet "http://localhost:9090/plugins/restapi/rest-api.jsp"
runCurlPost "http://localhost:9090/plugins/restapi/rest-api.jsp?save" "enabled=true&authtype=secret&secret=${restApiSecret}&customAuthFilterClassName=&allowedIPs=&loggingEnabled=false"
echo "rest api plugin configured"
