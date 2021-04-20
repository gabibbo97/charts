# gangway

[gangway](https://github.com/heptiolabs/gangway) is an application that can be used to easily enable authentication flows via OIDC for a kubernetes cluster.

## TL;DR

```bash
helm install gabibbo97/gangway \
  --set config.apiServerURL='https://api.example.com:6443' \
  --set config.authorizeURL='https://auth.example.com/auth' \
  --set config.tokenURL='https://auth.example.com/token' \
  --set config.clientSecret='superSecret' \
  --set config.sessionSecurityKey='superSecure'
```

## Introduction

This chart deploys a Gangway authentication server

## IMPORTANT SECURITY ADVICE

You __MUST__ set a `config.sessionSecurityKey`

## Configuration options

| Parameter                   | Description                                                               |                     Default                     |
| --------------------------- | ------------------------------------------------------------------------- | :---------------------------------------------: |
| `trustedCA.content`         | Specify inline a CA certificate                                           |                       ``                        |
| `trustedCA.secretName`      | Specify the CA certificate secret name                                    |                       ``                        |
| `config.clusterName`        | The name of the cluster to show on the generated KUBECONFIG               |                      `k8s`                      |
| `config.apiServerURL`       | The kubernetes API server url                                             |            `http://example.com:6443`            |
| `config.authorizeURL`       | The OIDC IDP Authorization URL                                            |            `http://example.com/auth`            |
| `config.tokenURL`           | The OIDC IDP Token URL                                                    |           `http://example.com/token`            |
| `config.audience`           | The OIDC IDP Userinfo URL                                                 |          `http://example.com/userinfo`          |
| `config.clientID`           | The OIDC Client ID                                                        |                    `gangway`                    |
| `config.clientSecret`       | The OIDC Client secret                                                    |                    `gangway`                    |
| `config.redirectURL`        | The redirect URL, will be defaulted to first configured ingress if absent |                       ``                        |
| `config.scopes`             | The OIDC scopes that will be requested                                    | `['openid','email','profile','offline_access']` |
| `config.usernameClaim`      | The OIDC username claim                                                   |                     `name`                      |
| `config.emailClaim`         | The OIDC username claim                                                   |                     `email`                     |
| `config.sessionSecurityKey` | The cookie security key                                                   |                 `verySecureKey`                 |
| `existingSecret`            | Specify an existing secret containing clientSecret and sessionSecurityKey |                       ``                        |

## Use of a selfsigned certificate / custom CA

In order to use a selfsigned certificate / custom CA, one can either:

- set `trustedCA.content` to the contents of the certificate
- set `trustedCA.secretName` to the name of a secret inside the gangway namespace

## Easy generation of the session security key

`tr -dc a-zA-Z0-9 < /dev/urandom | head -c 32; echo ''`
