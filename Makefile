charts := $(wildcard charts/*/)
scripts := $(wildcard scripts/**/*.sh)

# Docker related targets
ifneq ("$(shell which docker)","")
	DOCKER := docker
else ifneq ("$(shell which podman)","")
	DOCKER := podman
else
	$(error No container builder found)
endif

images := mongodb-assistant-images

docker-images: $(foreach img, $(images),$(images) )

mongodb-assistant-image := gabibbo97/helm-chart-mongodb-assistant:$(shell grep 'version' charts/mongodb/Chart.yaml | cut -d ':' -f 2 | tr -d '\n\t ')
mongodb-assistant-images:
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) docker-build-image context-dir=charts/mongodb image=$(mongodb-assistant-image)

mongodb-assistant-images-push:
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) docker-push-internal image=$(mongodb-assistant-image)

docker-build-image:
	$(DOCKER) build --tag $(image) $(context-dir)

docker-login:
	$(DOCKER) login -u "$$DOCKER_USERNAME" -p "$$DOCKER_PASSWORD" docker.io

docker-push: $(foreach img, $(images),$(images)-push )

docker-push-internal:
	$(DOCKER) push $(image) docker.io/$(image)
	$(DOCKER) push $(image) docker.io/$(shell echo $(image) | cut -d ':' -f 1):latest

# Minikube related targets
minikube-start: ## Startup local minikube cluster
	minikube status 2> /dev/null > /dev/null || minikube start --vm-driver kvm2 --memory 4000
	minikube update-context

minikube-delete: ## Delete local minikube cluster
	minikube delete

minikube-install-helm: minikube-start ## Install Helm inside a cluster
	helm version --server 2> /dev/null > /dev/null || helm init --wait

minikube-install-chart: minikube-install-helm ## Install the chart provided as parameter
ifeq ("$(chart)","")
	$(error Please set the chart parameter)
else
	helm upgrade $(chart) charts/$(chart) --install
endif
# Chart related targets
chart-lint: ## Lint all charts
	@$(foreach chart,$(charts),helm lint --strict $(chart);)

chart-package: ## Package all charts
	mkdir -p repo
	helm init --client-only
	@$(foreach chart,$(charts),helm dependency build $(chart);)
	@$(foreach chart,$(charts),helm package $(chart) --destination repo;)
ifneq ("$(wildcard repo/index.yaml)","")
	helm repo index --merge repo/index.yaml repo
else
	helm repo index repo
endif

# Testing targets
test-mongo:
	@scripts/tests/mongo.sh

test: test-mongo

# Script related targets
scripts-lint: ## Lint all scripts
	@$(foreach script,$(scripts),shellcheck -x $(script);)

# Meta-targets
.DEFAULT_GOAL := help
.PHONY: help
help:
	@echo Available targets:
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' Makefile | sort | sed -e 's/^\(.*\):.*## \(.*\)$$/  \1\t\2/g' | expand -t 40