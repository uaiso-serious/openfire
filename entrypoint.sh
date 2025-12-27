#!/bin/bash
set -e

export OPENFIRE_HOME=/opt/openfire

data_keystore() {

  if [[ -f "/data/security/keystore" ]]
  then
    echo "/data/security/keystore exists."
  else
    echo "moving keystore to /data/security/keystore"
    mkdir -p /data/security
    mv "${OPENFIRE_HOME}/resources/security/keystore" /data/security/keystore
  fi
  ln -sfn /data/security/keystore "${OPENFIRE_HOME}/resources/security/keystore"

}

data_embedded_db() {

  if [[ -d "/data/embedded-db" ]]
  then
    echo "/data/embedded-db exists."
  else
    echo "creating empty /data/embedded-db"
    mkdir -p /data/embedded-db
  fi
  ln -sfn /data/embedded-db "${OPENFIRE_HOME}/embedded-db"

}

data_conf() {
  if [[ -d "/data/conf" ]]
  then
    echo "/data/conf exists."
    rm -rf "${OPENFIRE_HOME}/conf"
  else
    echo "moving conf to /data/conf"
    mv "${OPENFIRE_HOME}/conf" /data/conf
  fi
  ln -sfn /data/conf "${OPENFIRE_HOME}/conf"
}

data_plugins() {

  if [[ -d "/data/plugins" ]]
  then
    echo "/data/plugins exists."
    rm -rf "${OPENFIRE_HOME}/plugins"
  else
    echo "moving plugins to /data/plugins"
    mv "${OPENFIRE_HOME}/plugins" /data/plugins
  fi
  ln -sfn /data/plugins "${OPENFIRE_HOME}/plugins"

}

data_vmoptions() {

  if [[ -f "/data/openfire.vmoptions" ]]
  then
    echo "${OPENFIRE_HOME}/bin/openfire.vmoptions symlink to /data/openfire.vmoptions"
    ln -sfn /data/openfire.vmoptions ${OPENFIRE_HOME}/bin/openfire.vmoptions
  else
    echo "not using /data/openfire.vmoptions"
  fi

}

data_keystore
data_embedded_db
data_conf
data_plugins
data_vmoptions

# allow arguments to be passed to openfire launch
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
fi

/opt/setup.sh &

LOGFILE=$(mktemp)
start-stop-daemon --start --chuid openfire:openfire \
 --exec "${OPENFIRE_HOME}/bin/openfire.sh" -- ${EXTRA_ARGS} > "$LOGFILE" 2>&1 &

OPENFIRE_PID=$!

echo "Waiting plugins..."
while ! grep -q "Finished processing all plugins." "$LOGFILE"; do
 sleep 1
done

echo "Plugins loaded."

/opt/setup-restapi.sh

wait $OPENFIRE_PID
