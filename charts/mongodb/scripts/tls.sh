#!/usr/bin/env sh
#
#   MongoDB TLS Helper
#
set -e
# Install openssl if not present
if [ -x "$(command -v apk)" ] && ! [ -x "$(command -v openssl)" ]; then apk add --no-cache openssl; fi
if [ -x "$(command -v apt)" ] && ! [ -x "$(command -v openssl)" ]; then apt-get update && apt-get install --yes openssl; fi
if [ -x "$(command -v dnf)" ] && ! [ -x "$(command -v openssl)" ]; then dnf install --assumeyes openssl; fi
if [ -x "$(command -v yum)" ] && ! [ -x "$(command -v openssl)" ]; then yum install --assumeyes openssl; fi
# Utility functions
log() {
  # Log a message as JSONL
  # $1 LEVEL    FATAL / ERROR / WARN / INFO / DEBUG
  # $2 MESSAGE

  # Ignore if we have been asked to print a debug message
  if [ "$1" = "DEBUG" ] && ! [ "$LOG_DEBUG" = "true" ]; then return; fi

  printf '{"timestamp":"%s","level":"%s","message":%s}\n' \
    "$(date -u -Iseconds)" \
    "$1" \
    "$2"

  # Exit on fatal error
  if [ "$1" = "FATAL" ]; then exit 1; fi
}
logText() {
  # Log a text message as JSONL
  # $1 LEVEL    FATAL / ERROR / WARN / INFO / DEBUG
  # $2 MESSAGE
  log "$1" "\"$2\""
}
mute() {
  # Run application, ignoring its output unless it errored
  OUTPUT="$(mktemp)"
  if eval "$1" > "$OUTPUT" 2>&1; then
    rm -f "$OUTPUT"
  else
    jsonError='{'
    jsonError="${jsonError}\"error\":\"Command execution failed\","
    jsonError="${jsonError}\"output_lines\":["
    first='true'
    while read -r line; do
      printLine="$(echo "$line" | tr '\t' ' ' | tr -s ' ')"
      if [ -z "$printLine" ]; then continue; fi
      if [ "$first" = "true" ]; then
        jsonError="${jsonError}\"${printLine}\""
        first='false'
      else
        jsonError="${jsonError},\"${printLine}\""
      fi
    done < "$OUTPUT"
    jsonError="${jsonError}]}"
    log 'FATAL' "$jsonError"
  fi
}

# Log startup
logText 'INFO' 'MongoDB TLS Helper started'

# Cryptographic functions
generatePrivateKey() {
  # Generates an RSA4096 key
  mute 'openssl genrsa -out server.key 4096 > /dev/null 2>&1'
}
generateCACertificate() {
  # Generate key
  generatePrivateKey
  openssl req -batch -new -x509 -sha512 -days 3650 -key server.key -out server.crt -config /dev/stdin > /dev/null 2> /dev/null <<EOF
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
O  = MongoDB - ${RELEASE_NAME}
EOF
  logText 'INFO' 'Created certificate authority'
  if [ -n "${CA_COPY_TO}" ]; then
    cp server.crt "${CA_COPY_TO}/ca.crt"
    cp server.key "${CA_COPY_TO}/ca.key"
    logText 'INFO' 'Copied certificate authority to storage'
  fi
}

getCA() {
  cp "${CA_CERTIFICATE}" ca.crt
  cp "${CA_KEY}" ca.key
  logText 'INFO' 'Copied certificate authority from storage'
}

signCertificate() {
  mute 'openssl req -batch -new -key server.key -out server.csr -config ext.conf'
  logText 'INFO' 'Generated CSR'
  mute 'openssl x509 -req -in server.csr -days 3650 -sha512 -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -extfile ext.conf -extensions mongo_server'
  logText 'INFO' 'Signed CSR'
  if [ -n "${CERT_CONCAT_TO}" ]; then
    cat server.key server.crt > "${CERT_CONCAT_TO}"
    logText 'INFO' 'Copied certificate to storage'
  fi
}

generateClientCertificate() {
  getCA
  generatePrivateKey
  cat > ext.conf <<EOF
[ req ]
prompt             = no
req_extensions     = mongo_server
distinguished_name = mongo_dn

[ mongo_server ]
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature
extendedKeyUsage     = clientAuth
subjectKeyIdentifier = hash

[ mongo_dn ]
CN = ${CLIENT_NAME}
O  = MongoDB - ${RELEASE_NAME}
OU = Users
EOF
  signCertificate
}

generateServerCertificate() {
  getCA
  generatePrivateKey
  cat > ext.conf <<EOF
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
O  = MongoDB - ${RELEASE_NAME}
OU = Members

[ mongo_san ]
IP.1  = 127.0.0.1
IP.2  = ${POD_IP}
DNS.1 = ${POD_NAME}
DNS.2 = ${POD_NAME}.${CLUSTER_NAME}
DNS.3 = ${POD_NAME}.${CLUSTER_NAME}.${POD_NAMESPACE}
DNS.4 = ${POD_NAME}.${CLUSTER_NAME}.${POD_NAMESPACE}.svc.cluster.local
DNS.5 = ${CLUSTER_NAME}.${POD_NAMESPACE}.svc.cluster.local
DNS.6 = ${CLUSTER_NAME}.${POD_NAMESPACE}
DNS.7 = localhost
EOF
  signCertificate
}

case ${TLS_HELPER} in
  CA)
    generateCACertificate
    ;;
  CLIENT)
    generateClientCertificate
    ;;
  SERVER)
    generateServerCertificate
    ;;
  *)
    if [ -z "$TLS_HELPER" ]; then
      logText 'FATAL' "TLS_HELPER is unset"
    else
      logText 'FATAL' "Unsupported TLS_HELPER value"
    fi
    ;;
esac

# Log termination
logText 'INFO' 'MongoDB TLS Helper terminated'