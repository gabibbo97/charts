# imagepullsecrets

Declarative configuration for imagepullsecrets

## Introduction

This Helm chart is a way to declaratively deploy imagepullsecrets to a Kubernetes cluster to use in a private registry context.

## TL;DR

```bash
helm install gabibbo97/imagepullsecrets \
  --set imagePullSecrets[0].registryURL="registry.k8s.example.com:5000" \
  --set imagePullSecrets[0].secretName="registry-pullsecret" \
  --set imagePullSecrets[0].username="user" \
  --set imagePullSecrets[0].password="password"
```

## Configuration options

| Parameter                                 | Description                                                | Default |
| ----------------------------------------- | ---------------------------------------------------------- | :-----: |
| `addAuthField`                            | Add `auth: <base64 encode of user:pass>` to the secret     | `true`  |
| `imagePullSecrets[n].registryURL`         | URL of the `n-th` registry                                 |  `""`   |
| `imagePullSecrets[n].secretName`          | Name of the imagepullsecret object for the `n-th` registry |  `""`   |
| `imagePullSecrets[n].username`            | Username for the `n-th` registry                           |  `""`   |
| `imagePullSecrets[n].password`            | Password for the `n-th` registry                           |  `""`   |
| `imagePullSecrets[n].annotations.<<KEY>>` | Annotations to set on the secret for the `n-th` registry   |  `{}`   |
| `imagePullSecrets[n].labels.<<KEY>>`      | Labels to set on the secret for the `n-th` registry        |  `{}`   |

## Usage

After creating a secret `registry-pullsecret` you can use it in two ways

### On a Pod

On the `Pod`, set `spec.imagePullSecrets[0].name=registry-pullsecret`

```yaml
kind: Pod
...
spec:
  ...
  imagePullSecrets:
  - name: registry-pullsecret
  ...
```

### On a ServiceAccount

On the `ServiceAccount`, set `imagePullSecrets[0].name=registry-pullsecret`

```yaml
kind: ServiceAccount
...
imagePullSecrets:
- name: registry-pullsecret
...
```

Then on pods that should consume that secret add `spec.serviceAccountName=my-service-account`

```yaml
kind: Pod
...
spec:
  ...
  serviceAccountName: my-service-account
  ...
```
