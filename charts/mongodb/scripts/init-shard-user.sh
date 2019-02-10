#!/usr/bin/env sh
#
# Initialize a MongoDB Shard user
#
# ENVIRONMENT VARIABLES (mandatory)
#   RELEASE_NAME                The release name
#

set -e

#
# Import utils
#
. /opt/mongoscripts/lib.sh

#
# Wait until the database reports being alive
#
until mongo --port 27017 --eval 'db.adminCommand({ ping:1 })' | grep 'ok' | grep -q '1'; do
    sleep 1
done
printf 'Router is alive\n'

while true; do
    # Create user
    USER_COMMAND="db.getSiblingDB(\"\$external\").runCommand("
    USER_COMMAND="${USER_COMMAND}{"
    USER_COMMAND="${USER_COMMAND}\"createUser\":\"O=MongoDB-${RELEASE_NAME},OU=Users,CN=HelmClusterRootUser\","
    USER_COMMAND="${USER_COMMAND}\"roles\":["
    USER_COMMAND="${USER_COMMAND}{\"role\":\"root\",\"db\":\"admin\"}"
    USER_COMMAND="${USER_COMMAND}],"
    USER_COMMAND="${USER_COMMAND}\"writeConcern\":{\"w\":\"majority\", \"wtimeout\": 5000}"
    USER_COMMAND="${USER_COMMAND}})"

    MONGO_RESULT="$(mktemp)"
    mongo --port 27017 --quiet --eval "${USER_COMMAND}" > "${MONGO_RESULT}"

    if grep 'ok' < "${MONGO_RESULT}" | grep -q '1'; then
        printf 'Correctly initialized user\n'
        waitForever
    elif grep -q 'Unauthorized' < "${MONGO_RESULT}"; then
        printf 'Authentication is already enabled\n'
        waitForever
    else
        printf 'Failed initializing user\n'
        exit 1
    fi
    rm -f "${MONGO_RESULT}"
done
