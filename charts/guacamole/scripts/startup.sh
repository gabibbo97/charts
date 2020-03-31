#!/bin/sh
set -e

/opt/guacamole-scripts/setup-proxy-valve.sh

exec /opt/guacamole/bin/start.sh "$@"
