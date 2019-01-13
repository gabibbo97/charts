# dex

[dex](https://github.com/dexidp/dex) is an OpenID Connect Identity (OIDC) and OAuth 2.0 Provider with Pluggable Connectors

## TL;DR

```bash
helm install gabibbo97/dex \
    --set ingress.host='https://auth.example.com' \
    --set ingress.tls.secretName='dex-tls-secret'
```

## Introduction

This chart bootstraps an in-cluster dex identity provider

## Configuration options

| Parameter         | Description            | Default |
| ----------------- | ---------------------- | :-----: |
| `connectors`      | List of Dex connectors |  `[]`   |
| `staticClients`   | List of Dex clients    |  `[]`   |
| `staticPasswords` | List of Dex users      |  `[]`   |

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

## Hurr durr how can I use this without TLS

You can't and you shouldn't
