#!/usr/bin/env sh
#
# Initialize a MongoDB Shard user
#
# ENVIRONMENT VARIABLES (mandatory)
#   RELEASE_NAME                The release name
#   SERVICE_PORT                The port where the service is exposed
#

set -e

#
# Import utils
#
. /opt/mongoscripts/lib.sh

#
# Wait until the database reports being alive
#
until mongo --port "${SERVICE_PORT}" --eval 'db.adminCommand({ ping:1 })' | grep 'ok' | grep -q '1'; do
    sleep 1
done
printf 'Router is alive\n'

#
# Wait until the replica set is initialized
#
while true; do
    # Check if authentication is already enabled
    if mongo --port "${SERVICE_PORT}" --eval 'sh.status()' | grep -q 'Unauthorized'; then
        printf 'Authentication is already enabled\n'
        waitForever
    fi

    # Check if already initialized
    if mongo --port "${SERVICE_PORT}" --quiet --eval 'rs.status()' | grep -q 'NotYetInitialized'; then
        printf 'Replica set is not yet initialized\n'
        sleep 5
        continue
    fi

    if mongo --port "${SERVICE_PORT}" --quiet --eval 'db.isMaster().ismaster' | grep -q 'false'; then
        printf 'Not master\n'
        sleep 5
        continue
    fi

    if mongo --port "${SERVICE_PORT}" --quiet --eval 'rs.myState()' | grep -q '1'; then
        printf 'Master\n'
    else
        sleep 5
        continue
    fi

    USER_COMMAND="db.getSiblingDB(\"\$external\").runCommand("
    USER_COMMAND="${USER_COMMAND}{"
    USER_COMMAND="${USER_COMMAND}\"createUser\":\"CN=HelmClusterRootUser,OU=Users,O=MongoDB-${RELEASE_NAME}\","
    USER_COMMAND="${USER_COMMAND}\"roles\":["
    USER_COMMAND="${USER_COMMAND}{\"role\":\"root\",\"db\":\"admin\"}"
    USER_COMMAND="${USER_COMMAND}],"
    USER_COMMAND="${USER_COMMAND}\"writeConcern\":{\"w\":\"majority\", \"wtimeout\": 5000}"
    USER_COMMAND="${USER_COMMAND}})"
    if mongo --port "${SERVICE_PORT}" --quiet --eval "${USER_COMMAND}" | grep 'ok' | grep -q '1'; then
        printf 'Correctly initialized user\n'
        waitForever
    else
        printf 'Failed initializing user\n'
        exit 1
    fi
done
