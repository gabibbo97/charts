#!/usr/bin/env sh
#
# Create a MongoDB certificate authority
#
# ENVIRONMENT VARIABLES (mandatory)
#   RELEASE_NAME            Sets the release name
#
# ENVIRONMENT VARIABLES (optional)
#   CA_DIR                  Directory to copy the CA key to
#

set -e
. /opt/mongoscripts/lib.sh

# Install openssl if not present
installPackage 'openssl'

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
