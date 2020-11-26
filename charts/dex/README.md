# dex

[dex](https://github.com/dexidp/dex) is an OpenID Connect Identity (OIDC) and OAuth 2.0 Provider with Pluggable Connectors

## TL;DR

```bash
helm install gabibbo97/dex
```

## Introduction

This chart bootstraps an in-cluster dex identity provider

## Configuration options

| Parameter                                  | Description                                                                    |             Default              |
| ------------------------------------------ | ------------------------------------------------------------------------------ | :------------------------------: |
| `connectors`                               | List of Dex connectors                                                         |               `[]`               |
| `staticClients`                            | List of Dex clients                                                            |               `[]`               |
| `staticPasswords`                          | List of Dex users                                                              |               `[]`               |
| `JSONLogging`                              | Enable JSON format for logs                                                    |             `false`              |
| `dexExternalURL`                           | URL that Dex will use as its own                                               | Value of `ingress.hosts[0].host` |
| `OAuth2.responseTypes`                     | The OAuth2 flows that will be supported                                        |            `['code']`            |
| `OAuth2.skipApprovalScreen`                | If possible avoid showing an approval screen                                   |              `true`              |
| `OAuth2.alwaysShowLoginScreen`             | Always show a login screen                                                     |             `false`              |
| `OAuth2.passwordConnector`                 | Use one of the predefined connectors instead of Dex to perform password grants |                ``                |
| `prometheusOperator.serviceMonitor.enable` | Deploy a `ServiceMonitor` resource                                             |             `false`              |

### Connectors

See the [documentation](https://github.com/dexidp/dex/tree/master/Documentation/connectors) for details

```yaml
connectors:
- type: <Connector kind>
  name: <Connector name>
  id: <Connector ID>
  config:
    <YAML Configuration>
```

### Static clients

```yaml
staticClients:
- id: <Client ID>
  redirectURIs:
  - <Redirect URI pattern>
  name: <Client name>
  secret: <Client secret>
  # Allow other client to issue tokens
  # Valid for this one
  # e.g. auth webapp and backend
  trustedPeers:
  - <Other client ID>
```

#### Easy generation of client secrets

`tr -dc a-zA-Z0-9 < /dev/urandom | head -c 32; echo ''`

### Static passwords

```yaml
- email: "<email>"
  hash: "<bcrypt hash>"
  username: "<username>"
```

#### Easy generation of bcrypt secrets

`htpasswd -bnBC 10 "usr" <Password> | cut -d ':' -f 2 | sed 's/2y/2a/'`

### Trying out your Dex installation

```sh
kubectl port-forward svc/dex 5555:http
curl -k 127.0.0.1:5555/.well-known/openid-configuration | jq
```

### Advanced configuration

This chart provides a _plug and play_ installation of Dex.

If you desire to manually configure Dex you can set up the variables `dexConfig` and `dexEnvironment` to have a completely custom installation of Dex.
