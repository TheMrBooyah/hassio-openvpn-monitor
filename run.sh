#!/bin/bash
set -e
CONFIG_PATH="/data/options.json"

mustache-cli $CONFIG_PATH /templates/server.mustache > /openvpn-monitor.conf

cat /openvpn-monitor.conf

exec "$@"