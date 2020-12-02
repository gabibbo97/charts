#!/bin/sh
#
# Grab readme index
#
find ./charts -mindepth 1 -maxdepth 1 -type d \
    | sort \
    | while read -r line; do
    if grep 'deprecated' "${line}/Chart.yaml" | grep -q 'true'; then
        printf "* __DEPRECATED__ [%s](%s)\n" \
            "$(echo $line | xargs basename)" \
            "$(echo $line | sed -e 's|^\./||')"
    else
        printf "* [%s](%s)\n" \
            "$(echo $line | xargs basename)" \
            "$(echo $line | sed -e 's|^\./||')"
    fi
done