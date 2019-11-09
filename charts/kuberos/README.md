# kuberos

[kuberos](https://github.com/negz/kuberos) is an OIDC authentication helper for Kubernetes

## A word of warning

kuberos has been deprecated by its owner, consider using Heptio's Gangway instead

## TL;DR

```bash
helm install gabibbo97/kuberos \
    --set ingress.enabled='true' \
    --set ingress.paths[0]='/' \
    --set ingress.hosts[0]='https://cluster.auth.example.com' \
    --set ingress.tls[0].secretName='kuberos-tls' \
    --set ingress.tls[0].hosts[0]='https://cluster.auth.example.com' \
    --set clusterName='my-k8s-cluster' \
    --set clusterAPIEndpoint='https://k8s.example.com:6443' \
    --set OIDCIssuerURL='https://auth.example.com' \
    --set OIDCClientID='kuberos' \
    --set OIDCClientSecret='secret'
```

## Introduction

This chart bootstraps an in-cluster dex identity provider

## Configuration options

| Parameter              | Description                                    |            Default             |
| ---------------------- | ---------------------------------------------- | :----------------------------: |
| `clusterName`          | The cluster name to set in kubeconfig          |             `k8s`              |
| `clusterAPIEndpoint`   | The cluster API endpoint                       | `https://k8s.example.com:6443` |
| `OIDCIssuerURL`        | The URL for the OIDC issuer                    |   `https://auth.example.com`   |
| `OIDCIssuerX509Secret` | A secret containing the issuer TLS certificate |              `""`              |
| `OIDCClientID`         | The OIDC client id                             |           `kuberos`            |
| `OIDCClientSecret`     | The OIDC client secret                         |            `secret`            |
| `OIDCExtraScopes`      | Extra scopes to add to authentication token    |              `[]`              |
