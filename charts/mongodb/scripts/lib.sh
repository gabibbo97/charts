#!/usr/bin/env sh
#
#   Common functionality shared between scripts
#

installPackage() {
    # Install the package provided as $1

    # Check if it was installed
    if [ -x "$(command -v "$1")" ]; then
        printf 'Package "%s" already present, skipping installation\n' "$1"
        return
    fi

    if [ -x "$(command -v apk)" ]; then apk add --no-cache "$1"; fi
    if [ -x "$(command -v apt)" ]; then apt-get update && apt-get install --yes "$1"; fi
    if [ -x "$(command -v dnf)" ]; then dnf install --assumeyes "$1"; fi
    if [ -x "$(command -v yum)" ]; then yum install --assumeyes "$1"; fi

}

waitDNS() {
    # Wait for a number of hosts via SRV queries
    #   $1  Desired server count
    #   $2  Service name
    #   $3  Namespace

    #
    # Install DIG
    #
    installPackage 'dnsutils'

    #
    # Perform DNS lookups to find out the server amount
    #
    DNS_LOOKUP="$(mktemp)"
    until [ "$(wc -l < "$DNS_LOOKUP")" = "${1}" ]; do
        dig +noall +answer SRV "${2}.${3}.svc.cluster.local" > "${DNS_LOOKUP}" 2> /dev/null
        sleep 1
    done

    printf 'DNS Check succeded for %d servers (Namespace: %s, Service: %s)\n' "$1" "$3" "$2"
}

waitForever() {
    # 'sleep infinity' is a GNU coreutils reserved function, sleep <LONGTIME> is more universal
    # Until we get a userspace program for the pause() syscall
    while true; do
        sleep infinity || sleep 3600
    done
}