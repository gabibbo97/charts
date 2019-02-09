#!/usr/bin/env sh
#
# Create a MongoDB server certificate
#
# ENVIRONMENT VARIABLES (mandatory)
#   CA_CRT                  The certificate authority certificate
#   CA_KEY                  The certificate authority key
#   CLUSTER_NAME            Kubernetes service name
#   POD_IP                  Kubernetes pod IP
#   POD_NAME                Kubernetes pod name
#   POD_NAMESPACE           Kubernetes pod namespace
#
# ENVIRONMENT VARIABLES (optional)
#   CA_DIR                  Directory to copy the CA key to
#   CERT_DIR                Directory to copy the server crt and key to
#

set -e
. /opt/mongoscripts/lib.sh

# Install openssl if not present
installPackage 'openssl'

# Generate private key
openssl genrsa -out server.key 4096

# Get CA
echo "${CA_CRT}" > CA.crt
echo "${CA_KEY}" > CA.key

# Copy OpenSSL configuration
cat > openssl.conf <<EOF
[ req ]
prompt             = no
req_extensions     = mongo_server
distinguished_name = mongo_dn

[ mongo_server ]
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature, nonRepudiation
subjectKeyIdentifier = hash
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @mongo_san

[ mongo_dn ]
CN = ${POD_NAME}
O  = MongoDB-${RELEASE_NAME}
OU = Members

[ mongo_san ]
IP.1  = 127.0.0.1
IP.2  = ${POD_IP}
DNS.1 = localhost
DNS.2 = ${POD_NAME}.${CLUSTER_NAME}
DNS.3 = ${POD_NAME}.${CLUSTER_NAME}.${POD_NAMESPACE}
DNS.4 = ${POD_NAME}.${CLUSTER_NAME}.${POD_NAMESPACE}.svc.cluster.local
DNS.5 = ${CLUSTER_NAME}.${POD_NAMESPACE}.svc.cluster.local
DNS.6 = ${CLUSTER_NAME}.${POD_NAMESPACE}
EOF

# Generate CSR
openssl req -batch -new -key server.key -out server.csr -config openssl.conf

# Sign certificate
openssl x509 -req -in server.csr -days 3650 -sha512 -CA CA.crt -CAkey CA.key -CAcreateserial -out server.crt -extfile openssl.conf -extensions mongo_server

# Perform copies
if [ -n "${CERT_DIR}" ]; then
    cp server.crt "${CERT_DIR}/server.crt"
    cp server.key "${CERT_DIR}/server.key"
    cat server.key server.crt > "${CERT_DIR}/server.pem"
fi
if [ -n "${CA_DIR}" ]; then
    cp CA.crt "${CA_DIR}/ca.pem"
fi
