# imagepullsecrets

Declarative configuration for imagepullsecrets

## Introduction

This Helm chart is a way to declaratively deploy imagepullsecrets to a Kubernetes cluster to use in a private registry context.

## TL;DR

```bash
helm install gabibbo97/imagepullsecrets \
  --set imagePullSecret.registryURL="registry.k8s.example.com:5000" \
  --set imagePullSecret.secretName="registry-pullsecret" \
  --set imagePullSecret.username="user" \
  --set imagePullSecret.password="password"
```

## Configuration options

| Parameter                             | Description                                            | Default |
| ------------------------------------- | ------------------------------------------------------ | :-----: |
| `addAuthField`                        | Add `auth: <base64 encode of user:pass>` to the secret | `true`  |
| `imagePullSecret.registryURL`         | URL of the registry                                    |  `""`   |
| `imagePullSecret.secretName`          | Name of the imagepullsecret object for the registry    |  `""`   |
| `imagePullSecret.username`            | Username for the registry                              |  `""`   |
| `imagePullSecret.password`            | Password for the registry                              |  `""`   |
| `imagePullSecret.annotations.<<KEY>>` | Annotations to set on the secret for the registry      |  `{}`   |
| `imagePullSecret.labels.<<KEY>>`      | Labels to set on the secret for the registry           |  `{}`   |

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
---
imagePullSecrets:
  - name: registry-pullsecret
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
