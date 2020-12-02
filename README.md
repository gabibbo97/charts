# gabibbo97 Helm chart

Hello, these are charts that I find useful in my day to day business.

Many of these charts are opinionated around the concept of cloud-nativeness instead of simply packaging an application and deploying it, we should be leveraging immutable,  declarative, auditable configuration from day1.

The repo is actually a misomer because there are many k8s related utilities that are related to this repo.

## Quickstart

```bash
helm repo add gabibbo97 https://gabibbo97.github.io/charts/
helm repo update
```

## Repository contents

### Charts

* [389ds](charts/389ds)
* [dex](charts/dex)
* __DEPRECATED__ [fcgi-nginx-frontend](charts/fcgi-nginx-frontend)
* [gangway](charts/gangway)
* [guacamole](charts/guacamole)
* [imagepullsecrets](charts/imagepullsecrets)
* __DEPRECATED__ [keycloak-gatekeeper](charts/keycloak-gatekeeper)
* __DEPRECATED__ [kuberos](charts/kuberos)
* [ldap-account-manager](charts/ldap-account-manager)
* __DEPRECATED__ [mongodb](charts/mongodb)
* [papermc](charts/papermc)
* __DEPRECATED__ [periodic-daemonset](charts/periodic-daemonset)
* __DEPRECATED__ [pullsecret](charts/pullsecret)