#!/usr/bin/env sh
set -e

# Get this computer ip
NETWORK_DEVICE=$(ip route | grep default | awk '{ print $5 }')
NETWORK_ADDRESS=$(ip route | grep "$NETWORK_DEVICE" | grep src | awk '{ print $9 }')
printf '%s: %s\n' \
  "Network device" "$NETWORK_DEVICE" \
  "Network address" "$NETWORK_ADDRESS"

# Create Docker registry htpasswd file
mkdir -p /tmp/tests
htpasswd -nBb testUser testPass > /tmp/tests/htpasswd

# Launch Docker registry
sudo docker pull registry
if sudo docker ps | grep -q 'docker-registry'; then sudo docker rm -f docker-registry; fi
sudo docker run \
  --detach --rm \
  --net host \
  --name docker-registry \
  -v /tmp/tests:/etc/dockertest:Z \
  -e REGISTRY_AUTH_HTPASSWD_REALM=testRealm \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/etc/dockertest/htpasswd \
  registry

# Download and tag image
sudo docker run \
  --rm --net host --privileged \
  --entrypoint /bin/sh \
  docker:dind \
  -c "dockerd --insecure-registry=192.168.0.0/16 & until docker info > /dev/null; do sleep 1;done && docker pull ubuntu:18.04 && docker tag ubuntu:18.04 $NETWORK_ADDRESS:5000/ubuntu:18.04 && docker login -u testUser -p testPass $NETWORK_ADDRESS:5000 && docker push $NETWORK_ADDRESS:5000/ubuntu:18.04"


# Deploy helm
helm version --server || helm init --wait

# Deploy the chart
helm upgrade pullsecret-test charts/pullsecret \
  --atomic \
  --install \
  --set registryURL="http://$NETWORK_ADDRESS:5000" \
  --set registryUsername="testUser" \
  --set registryPassword="testPass" \
  --set secretName="test-pull-secret"

# Deploy the pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  imagePullSecrets:
    - name: test-pull-secret
  containers:
    - name: test-pod
      image: $NETWORK_ADDRESS:5000/ubuntu:18.04
      imagePullPolicy: Always
      command:
        - /bin/sh
        - -ec
      args:
        - |-
          while true
          do
            printf 'Hello there\n'
            sleep 30
          done
EOF

# Test
until kubectl get pod | grep test-pod | grep -q 'Running'
do
  sleep 3
  printf 'Waiting for pod to become running\n'
done
printf 'Test successful!\n'

# Cleanup
kubectl delete pod test-pod
sudo docker rm -f docker-registry
rm -f /tmp/tests/htpasswd