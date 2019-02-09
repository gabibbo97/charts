#!/usr/bin/env sh
#
# Create a MongoDB client certificate
#
# ENVIRONMENT VARIABLES (mandatory)
#   CA_CRT                  The certificate authority certificate
#   CA_KEY                  The certificate authority key
#   USER_NAME               Common name of the end certificate
#   RELEASE_NAME            Sets the release name
#
# ENVIRONMENT VARIABLES (optional)
#   CA_DIR                  Directory to copy the CA key to
#   CERT_DIR                Directory to copy the client crt and key to
#

set -e
. /opt/mongoscripts/lib.sh

# Install openssl if not present
installPackage 'openssl'

# Generate private key
openssl genrsa -out client.key 4096

# Get CA
echo "${CA_CRT}" > CA.crt
echo "${CA_KEY}" > CA.key

# Copy OpenSSL configuration
cat > openssl.conf <<EOF
[ req ]
prompt             = no
req_extensions     = mongo_client
distinguished_name = mongo_dn

[ mongo_client ]
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature
subjectKeyIdentifier = hash
extendedKeyUsage     = clientAuth

[ mongo_dn ]
CN = ${USER_NAME}
O  = MongoDB-${RELEASE_NAME}
OU = Users
EOF

# Generate CSR
openssl req -batch -new -key client.key -out client.csr -config openssl.conf

# Sign certificate
openssl x509 -req -in client.csr -days 3650 -sha512 -CA CA.crt -CAkey CA.key -CAcreateserial -out client.crt -extfile openssl.conf -extensions mongo_client

# Perform copies
if [ -n "${CERT_DIR}" ]; then
    cp client.crt "${CERT_DIR}/client.crt"
    cp client.key "${CERT_DIR}/client.key"
    cat client.key client.crt > "${CERT_DIR}/client.pem"
fi
if [ -n "${CA_DIR}" ]; then
    cp CA.crt "${CA_DIR}/ca.pem"
fi
