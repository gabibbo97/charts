#!/usr/bin/env bash
# Allow easy testing using minikube
if [ -z "$1" ]; then
  printf '%s\n' \
    "$0 <CHART_NAME>" > /dev/stderr
  exit 1
fi

CHART_NAME="$1"
shift

deleteChart() {
  if helm ls --all | grep -q "$CHART_NAME"; then
    helm delete --purge "$CHART_NAME" 2> /dev/null || true
  fi
}

trap deleteChart EXIT ERR

set -e
# Startup
minikubeStart() {
  if minikube status > /dev/null; then
    printf '✓ Minikube already started\n'
  else
    minikube start --vm-driver=kvm2 --cpus 2 --memory 4000
    clear
    printf '✓ Minikube startup completed\n'
  fi
}
minikubeStart
minikube update-context
# Configuration
minikubeSetAddon() {
  # $1 addon name
  # $2 state
  case $2 in
    disabled|d)
      minikube addons list | grep "$1" | grep -q 'disabled' || minikube addons enable "$1"
      ;;
    enabled|e)
      minikube addons list | grep "$1" | grep -q 'enabled' || minikube addons enable "$1"
      ;;
    *) printf 'Unknown parameter to minikubeSetAddon\n' > /dev/stderr && exit 1
  esac
}
minikubeConfig() {
  minikubeSetAddon 'dashboard'            'disabled'
  minikubeSetAddon 'default-storageclass' 'enabled'
  minikubeSetAddon 'ingress'              'enabled'
  minikubeSetAddon 'storage-provisioner'  'enabled'
}
minikubeConfig
# Helm setup
helm init --wait
# Helm upgrade
helm upgrade "$CHART_NAME" "charts/$CHART_NAME" --install "$@"
# Exit
read -r -p "Press any key to destroy deployment"
