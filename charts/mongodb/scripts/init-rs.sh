#!/usr/bin/env sh
#
# Initialize a MongoDB Replica Set
#
# ENVIRONMENT VARIABLES (mandatory)
#   SERVER_COUNT                The number of servers in the replica set
#   SERVICE_NAME                The name of the headless service
#   REPLICA_SET_NAME            The name of the replica set
#   POD_NAMESPACE               Kubernetes pod namespace
#

set -e

#
# Import utils
#
. /opt/mongoscripts/lib.sh


#
# Perform initialization only on first host
#
if [ "$(hostname | cut -d '.' -f 1 | rev | cut -d '-' -f 1)" = "0" ]; then
    printf 'Running on the first node\n'
else
    printf 'Running not on the first node, skipping initialization\n'
    waitForever
fi

#
# Wait until every server is alive
#
waitDNS "${SERVER_COUNT}" "${SERVICE_NAME}" "${POD_NAMESPACE}"

#
# Generate replica set document
#
RS_DOCUMENT="$(mktemp)"
firstHost='true'
INDEX=0
printf '{' > "$RS_DOCUMENT"
printf '"_id":"%s",' "${REPLICA_SET_NAME}" >> "$RS_DOCUMENT"
if [ "${IS_CONFIGSVR}" = "true" ]; then
    printf '"configsvr":true,' >> "$RS_DOCUMENT"
fi
printf '"members":[' >> "$RS_DOCUMENT"
while read -r line; do
    DB_PORT="$(echo "$line" | awk '{ print $7 }')"
    DB_HOSTNAME="$(echo "$line" | awk '{ print $8 }' | sed -e 's/\.$//')"
    # Print comma between members
    if [ "${firstHost}" = "true" ]; then
        firstHost='false'
    else
        printf ',' >> "$RS_DOCUMENT"
    fi
    # Print configuration document
    printf '{"_id":%d,"host":"%s:%d"}' "${INDEX}" "${DB_HOSTNAME}" "${DB_PORT}" >> "$RS_DOCUMENT"
    INDEX=$(( INDEX + 1 ))
done < "${DNS_LOOKUP}"
printf ']' >> "$RS_DOCUMENT"
printf '}' >> "$RS_DOCUMENT"
cat "$RS_DOCUMENT"

#
# Check if the replica set is initialized
#
if mongo --port "$DB_PORT" --quiet --eval 'rs.status()' | grep -q 'NotYetInitialized'; then
    printf 'Replica set is not yet initialized\n'
    RS_BOOTSTRAP_RESULT="$(mktemp)"
    mongo --port "$DB_PORT" --quiet --eval "rs.initiate($(cat < "${RS_DOCUMENT}"))" > "$RS_BOOTSTRAP_RESULT"
    if grep 'ok' < "$RS_BOOTSTRAP_RESULT" | grep -q '0'; then
        printf 'Bootstrap failed!\n'
        exit 1
    else
        printf 'Bootstrap succeded\n'
    fi
else
    printf 'Replica set is already initialized\n'
fi

waitForever