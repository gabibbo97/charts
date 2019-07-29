# Pullsecret

MongoDB is an Object Oriented database with easy clustering capabilities

## TL;DR

```bash
helm install gabibbo97/mongodb
```

## Configuration options

| Parameter                      | Description                                  |      Default      |
| ------------------------------ | -------------------------------------------- | :---------------: |
| `mode`                         | Which mode should the replica set operate in |   `standalone`    |
| `replicaSetName`               | The name of the replica set                  |       `rs0`       |
| `replicaSetTopology.arbiters`  | The number of arbiters in the replica set    |        `1`        |
| `replicaSetTopology.data`      | The number of data nodes in the replica set  |        `2`        |
| `extraArgs`                    | Extra arguments to pass to `mongod`          | Various arguments |
| `persistence.enabled`          | Enable data persistence                      |      `true`       |
| `persistence.size`             | Data persistence size                        |       `2Gi`       |
| `persistence.storageClassName` | Storage class name, empty for default        |        ``         |
| `pdb.enabled`                  | Enable PodDisruptionBudgets                  |      `true`       |
| `pdb.minArbiters`              | Minimum number of arbiters                   |        `1`        |
| `pdb.minDataServers`           | Minimum number of data servers               |        `1`        |
| `enabledJobs.rsConfiguration`  | Enable replica set reconfiguration job       |      `true`       |

