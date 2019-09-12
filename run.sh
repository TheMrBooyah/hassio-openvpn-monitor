#!/bin/bash
set -e
CONFIG_PATH="/data/options.json"

curl -X GET \
    -H "x-ha-access: $HASSIO_TOKEN" \
    -H "Content-Type: application/json" \
    -o "/data/config.json" \
    http://hassio/homeassistant/api/config

mustache-cli $CONFIG_PATH /templates/server.mustache --override /data/config.json > ./openvpn-monitor.conf

cat ./openvpn-monitor.conf

exec "$@"