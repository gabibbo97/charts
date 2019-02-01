#!/usr/bin/env sh
set -e

# Install mongodb
helm install --name mongodb charts/mongodb \
    --set topology.configServers=3 \
    --set topology.shards.count=1 \
    --set topology.routers=1 \
    --wait
# Uninstall mongodb
helm delete --purge mongodb
