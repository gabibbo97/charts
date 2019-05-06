# Pullsecret

This is an utility chart that allows deploying a pullsecret.

It is not very useful by himself but can be leveraged as a dependency

## TL;DR

```bash
helm install gabibbo97/pullsecret \
    --set secretName=my-pull-secret \
    --set registryURL=http://registry.example.com:5000 \
    --set registryUsername=testUser \
    --set registryPassword=testPass
```

## Configuration options

| Parameter          | Description               |            Default            |
| ------------------ | ------------------------- | :---------------------------: |
| `secretName`       | The secret name           |              ``               |
| `registryURL`      | URL of the registry       | `https://index.docker.io/v1/` |
| `registryUsername` | Registry username         |              ``               |
| `registryPassword` | Registry password         |              ``               |
| `registryEmail`    | (Optional) Registry email |              ``               |


## How to use the pullsecret

### In a Pod

```yaml
apiVersion: v1
kind: Pod
...
spec:
  ...
  imagePullSecrets:
    - name: <<secretName>>
  ...
```

### In a ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
...
imagePullSecrets:
  - name: <<secretName>>
...
```