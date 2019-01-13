# periodic-daemonset

Periodic daemonset allows scheduling a Pod across all nodes in the cluster

## TL;DR

```bash
helm install gabibbo97/periodic-daemonset \
    --set schedule='*/3 * * * *' \
    --values /dev/stdin <<EOF
podSpec:
  containers:
    - name: hello-world
      image: alpine:latest
      imagePullPolicy: Always
      command:
        - /bin/sh
        - -c
      args:
        - echo "Hello world"
EOF
```

## Introduction

This chart periodically launches a pod across all hosts

## Configuration options

| Parameter  | Description                  |      Default       |
| ---------- | ---------------------------- | :----------------: |
| `schedule` | The schedule for the cronjob |   `*/3 * * * *`    |
| `podSpec`  | The pod for the cronjob      | An hello world pod |
