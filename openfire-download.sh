#!/bin/bash
FILE=openfire.tar.gz
if [ ! -f "$FILE" ]; then
    wget https://github.com/igniterealtime/Openfire/releases/download/v5.0.3/openfire_5_0_3.tar.gz -nv -O ${FILE}
fi
