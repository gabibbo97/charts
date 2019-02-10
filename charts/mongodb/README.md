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

## Cluster management 101

### Accessing the cluster

To access the cluster please ensure that you have valid credentials

This guide assumes that

- `ca.crt` is the cluster certificate authority
- `client.pem` is the concatenation of the client key and certificate

#### Containerized

Forward the cluster to localhost using `kubectl port-forward`

##### Docker / Podman

You can use either `docker` or `podman`, the syntax is the same

```bash
sudo podman run \
        --rm --it --net host \
        --volume "$(pwd):/creds" \
        --entrypoint 'mongo' \
        mongo \
                --ssl --sslCAFile /creds/ca.crt --sslPEMKeyFile /creds/client.pem \
                --authenticationDatabase '$external' --authenticationMechanism 'MONGODB-X509' \
                --host 'localhost'
```

##### From cluster

```bash
kubectl run --rm -it --restart=Never --image=mongo mongopod -- \
        mongo --ssl --sslCAFile /creds/ca.crt --sslPEMKeyFile /creds/client.pem \
                --authenticationDatabase '$external' --authenticationMechanism 'MONGODB-X509' \
                mongodb+srv://mongodb-router.default.svc.cluster.local
```