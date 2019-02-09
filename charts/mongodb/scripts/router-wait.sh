#!/usr/bin/env sh
#
# Wait for all components to be at the target topology
#
# ENVIRONMENT VARIABLES (mandatory)
#   NAME_PREFIX                 The name prefix of all resources
#   CONFIG_SERVERS              The number of config servers
#   SHARDS_COUNT                The number of shards
#   SHARDS_SIZE                 The number of servers for each shard
#

set -e

#
# Import utils
#
. /opt/mongoscripts/lib.sh

# Config server
waitDNS "${CONFIG_SERVERS}" "${NAME_PREFIX}-configsvr" "${POD_NAMESPACE}"

# Shards
for i in $(seq 0 $(( SHARDS_COUNT - 1 ))); do
    waitDNS "${SHARDS_SIZE}" "${NAME_PREFIX}-shard-${i}-shardsvr" "${POD_NAMESPACE}"
done

