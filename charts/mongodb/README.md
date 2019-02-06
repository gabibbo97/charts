# mongodb

This is ALPHA QUALITY SOFTWARE, DO NOT INSTALL UNLESS YOU WANT TO ENGAGE IN DEVELOPMENT

[mongodb](https://www.mongodb.com) is an Object Oriented database that provides easy clustering capabilities

## TL;DR

```bash
helm install gabibbo97/mongodb
```

## Configuration options

| Parameter                             | Description                                                  | Default  |
| ------------------------------------- | ------------------------------------------------------------ | :------: |
| `isolateClusterWithNetworkPolicy`     | Isolate the cluster from the other services                  |  `true`  |
| `persistentVolumeClaims.enabled`      | Should the chart use persistentVolumeClaims                  | `false`  |
| `persistentVolumeClaims.size`         | Minimum size of a persistent volume                          |  `2Gi`   |
| `podDisruptionPolicies.configServers` | How many config servers should be kept available             |   `2`    |
| `podDisruptionPolicies.routers`       | How many routers should be kept available                    |   `1`    |
| `podDisruptionPolicies.shardServers`  | How many shard servers should be kept available              |   `2`    |
| `tls.ca.managementMode`               | How to generate root CA for X509 authentication              | `script` |
| `topology.configServers`              | How many servers to include in the configuration replica set |   `3`    |
| `topology.routers`                    | How many routers to deploy                                   |   `2`    |
| `topology.shards.count`               | How many shards to deploy                                    |   `3`    |
| `topology.shards.servers`             | How many servers to deploy for each shard                    |   `3`    |

## How the different parts interact

```text
+----------------+
| MongoDB Client |
+-------+--------+
        |
        |
        v           Ask about shard distribution
+-------+--------+------------------------------> +-----------------------+
| MongoDB Router |                                | MongoDB Config Server |
+-------+--------+ <------------------------------+-----------------------+
        |           Reply with shard configuration
        |
        |
+-------v--------+
| MongoDB Shard  |
+----------------+
```
