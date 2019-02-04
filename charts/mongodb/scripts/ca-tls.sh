#!/usr/bin/env sh

set -e

# Install openssl if not present
if [ -x "$(command -v apk)" ] && ! [ -x "$(command -v openssl)" ]; then apk add --no-cache openssl; fi
if [ -x "$(command -v apt)" ] && ! [ -x "$(command -v openssl)" ]; then apt-get update && apt-get install --yes openssl; fi
if [ -x "$(command -v dnf)" ] && ! [ -x "$(command -v openssl)" ]; then dnf install --assumeyes openssl; fi
if [ -x "$(command -v yum)" ] && ! [ -x "$(command -v openssl)" ]; then yum install --assumeyes openssl; fi

# Generate private key
openssl genrsa -out ca.key 4096

# Copy OpenSSL configuration
cat > openssl.conf <<EOF
[ req ]
prompt             = no
x509_extensions    = mongo_ca
distinguished_name = mongo_dn

[ mongo_ca ]
basicConstraints     = critical, CA:TRUE, pathlen:0
keyUsage             = keyCertSign, cRLSign
subjectKeyIdentifier = hash

[ mongo_dn ]
CN = MongoDB Cluster CA
O  = MongoDB-${RELEASE_NAME}
EOF

# Generate certificate
openssl req -batch -new -x509 -sha512 -days 3650 -key ca.key -out ca.crt -config openssl.conf

# Perform copies
if [ -n "${CA_DIR}" ]; then
    cp ca.crt "${CA_DIR}/ca.crt"
    cp ca.key "${CA_DIR}/ca.key"
fi
