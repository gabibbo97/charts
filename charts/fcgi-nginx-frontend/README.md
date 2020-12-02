# fcgi-nginx-frontend

This chart allows exposing a FastCGI deployment via HTTP, this can be used with PHP-FPM and such

## DEPRECATION NOTICE

This has been deprecated because ingress controllers now offer this as a built-in functionality.

See for instance the documentation of ingress-nginx on [exposing FastCGI servers](https://kubernetes.github.io/ingress-nginx/user-guide/fcgi-services).

## TL;DR

```bash
helm install gabibbo97/fcgi-nginx-frontend \
    --set fastcgiBackend=php-fpm.namespace.svc:9000 \
    --set fastcgiParams.SCRIPT_FILENAME=/var/www/html/index.php
```

## Introduction

This chart can be used to expose a FCGI server

## Configuration options

|          Value          | Description                                                    |        Default         |
| :---------------------: | -------------------------------------------------------------- | :--------------------: |
|     `replicaCount`      | Number of replicas to deploy                                   |         `true`         |
|   `image.repository`    | Repository for the container image                             |        `nginx`         |
|   `image.pullPolicy`    | Pull policy for the container image                            |     `IfNotPresent`     |
|     `nameOverride`      | Name to utilize                                                |           ``           |
|   `fullnameOverride`    | Name to utilize                                                |           ``           |
| `serviceAccount.create` | Create automatically a service account                         |         `true`         |
|  `serviceAccount.name`  | The service account name                                       |         `None`         |
|     `service.type`      | The type of the service that will be created                   |      `ClusterIP`       |
|     `service.port`      | The port of the service that will be created                   |          `80`          |
|    `ingress.enabled`    | Expose the service with an ingress resource                    |        `false`         |
| `ingress.hosts[0].host` | Hostname for this ingress                                      | `chart-example.local`  |
|    `fastcgiBackend`     | The FastCGI server backend                                     |           ``           |
|     `fastcgiIndex`      | The page to redirect any request without a proper request line |      `index.php`       |
|    `fastcgiParams.*`    | Parameters to pass to FCGI backend                             | `$fastcgi_script_name` |
|      `serverBlock`      | The raw NGINX server block                                     |       `<CONFIG>`       |
