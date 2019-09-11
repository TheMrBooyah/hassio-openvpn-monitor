#!/bin/bash
set -e
CONFIG_PATH="/data/options.json"

curl -X GET \
    -H "X-HASSIO-KEY: $HASSIO_TOKEN" \
    -H "Content-Type: application/json" \
    -o "/data/config.json" \
    http://hassio/homeassistant/api/config

cat /data/config.json

mustache-cli $CONFIG_PATH /templates/server.mustache > ./openvpn-monitor.conf

cat ./openvpn-monitor.conf

exec "$@"