#!/bin/bash

adminpassword=${ADMIN_PASSWORD:-"admin"}
restApiSecret=${REST_API_SECRET:-"myrestapisecret"}

runLogin () {
  header=$(curl -Is 'http://localhost:9090/login.jsp')
  CSRF=$(echo "$header" | grep -iE '^Set-Cookie: csrf=' | sed 's/.*csrf=\([^;]*\).*/\1/')
  JSESSIONID=$(echo "$header" | grep -iE '^Set-Cookie: JSESSIONID=' | sed 's/.*JSESSIONID=\([^;]*\).*/\1/')

  header=$(curl -is 'http://localhost:9090/login.jsp' -H 'Content-Type: application/x-www-form-urlencoded' -H "Cookie: JSESSIONID=$JSESSIONID; csrf=$CSRF;" --data-raw "login=true&csrf=$CSRF&username=admin&password=$adminpassword")
  CSRF=$(echo "$header" | grep -iE '^Set-Cookie: csrf=' | sed 's/.*csrf=\([^;]*\).*/\1/')
  JSESSIONID=$(echo "$header" | grep -iE '^Set-Cookie: JSESSIONID=' | sed 's/.*JSESSIONID=\([^;]*\).*/\1/')
}

runLogin
HTTPCODE=$(curl -o /dev/null -I -s -w "%{http_code}\n" "http://localhost:9090/plugins/restapi/v1/system/readiness" -b "JSESSIONID=$JSESSIONID")

if [ "$HTTPCODE" = "200" ]; then
  EXPECTED='{"key":"adminConsole.access.allow-wildcards-in-excludes","value":"true"}'
  RESPONSE=$(curl -s \
    'http://localhost:9090/plugins/restapi/v1/system/properties/adminConsole.access.allow-wildcards-in-excludes' \
    -H 'accept: application/json' \
    -H "Authorization: ${restApiSecret}")
  echo "Expected: [${EXPECTED}]"
  echo "Response: [${RESPONSE}]"
  diff -q <(echo "$EXPECTED") <(echo "$RESPONSE")
  if ! diff -q <(echo "$EXPECTED") <(echo "$RESPONSE") >/dev/null; then
    exit 1
  fi
  sleep 10
  exit 0
fi
exit 1
