#!/usr/bin/env bash
set -e
#
# Setup a demo environment that leverages charts inside this repository
#
K8S_CLIENT_SECRET="$(tr -dc a-zA-Z0-9 < /dev/urandom | head -c 32)"
KUBEROS_CLIENT_SECRET="$(tr -dc a-zA-Z0-9 < /dev/urandom | head -c 32)"
MINIKUBE_IP="$(minikube ip)"

# Create TLS payload
TLS_CRT="$(mktemp)"
TLS_KEY="$(mktemp)"
openssl req -batch \
  -new -x509 \
  -newkey rsa:4096 -nodes \
  -days 3650 \
  -subj "/CN=dex.${MINIKUBE_IP}.xip.io/O=K8S/" \
    -out "${TLS_CRT}" -keyout "${TLS_KEY}"
kubectl -n auth delete secret dex-ingress-tls --ignore-not-found
kubectl -n auth create secret tls dex-ingress-tls --cert "${TLS_CRT}" --key "${TLS_KEY}"
rm "${TLS_CRT}" "${TLS_KEY}"

# Dex
helm install \
  charts/dex \
  --name dex \
  --namespace auth \
  --set ingress.host="dex.${MINIKUBE_IP}.xip.io" \
  --set ingress.tls.secretName="dex-ingress-tls" \
  --set staticClients[0].id=k8s \
  --set staticClients[0].name=Kubernetes \
  --set staticClients[0].secret="${K8S_CLIENT_SECRET}" \
  --set staticClients[0].trustedPeers[0]=kuberos \
  --set staticClients[1].id=kuberos \
  --set staticClients[1].name='Kubernetes CLI Auth' \
  --set staticClients[1].secret="${KUBEROS_CLIENT_SECRET}" \
  --set staticClients[1].redirectURIs[0]="https://kuberos.${MINIKUBE_IP}.xip.io/ui" \
  --set staticPasswords[0].email=user@example.com \
  --set staticPasswords[0].hash='$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W' \
  --set staticPasswords[0].username=user

# Kuberos
helm install \
  charts/kuberos \
  --name kuberos \
  --namespace auth \
  --set ingress.enabled='true' \
  --set ingress.paths[0]='/' \
  --set ingress.hosts[0]="kuberos.${MINIKUBE_IP}.xip.io" \
  --set ingress.tls[0].secretName='kuberos-tls' \
  --set ingress.tls[0].hosts[0]="kuberos.${MINIKUBE_IP}.xip.io" \
  --set OIDCIssuerURL="https://dex.${MINIKUBE_IP}.xip.io" \
  --set OIDCIssuerX509Secret="dex-ingress-tls" \
  --set OIDCClientID='kuberos' \
  --set OIDCClientSecret="${KUBEROS_CLIENT_SECRET}"

read -r -p "Waiting for a keypress"
helm delete --purge 'dex' || true
helm delete --purge 'kuberos' || true
kubectl -n auth delete secret dex-ingress-tls
