#!/usr/bin/env sh
#
# ARGUMENTS
#   upload                  Upload a crt + key pair to Kubernetes
#   delete                  Delete a crt + key pair from Kubernetes
#
# ENVIRONMENT VARIABLES (mandatory)
#   SECRET_NAME             The name the secret should have
#   CERT_CRT                The certificate location
#   CERT_KEY                The key location
#

set -e

# Install curl if not present
if [ -x "$(command -v apk)" ] && ! [ -x "$(command -v curl)" ]; then apk add --no-cache curl; fi
if [ -x "$(command -v apt)" ] && ! [ -x "$(command -v curl)" ]; then apt-get update && apt-get install --yes curl; fi
if [ -x "$(command -v dnf)" ] && ! [ -x "$(command -v curl)" ]; then dnf install --assumeyes curl; fi
if [ -x "$(command -v yum)" ] && ! [ -x "$(command -v curl)" ]; then yum install --assumeyes curl; fi

if [ "$1" = "upload" ]; then
  cat > request.json <<EOF
{
  "apiVersion" : "v1",
  "kind" : "Secret",
  "metadata" : {
    "name" : "${SECRET_NAME}",
    "namespace" : "$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)"
  },
  "data" : {
    "tls.crt" : "$(base64 -w0 < "${CERT_CRT}")",
    "tls.key" : "$(base64 -w0 < "${CERT_KEY}")"
  },
  "type" : "kubernetes.io/tls"
}
EOF
  curl \
    -X POST \
    --data @request.json \
    --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
      "https://kubernetes.default/api/v1/namespaces/$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)/secrets"
fi

if [ "$1" = "delete" ]; then
  curl \
    -X DELETE \
    --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
      "https://kubernetes.default/api/v1/namespaces/$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)/secrets/${SECRET_NAME}"
fi