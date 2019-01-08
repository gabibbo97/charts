#!/usr/bin/env sh
mkdir -p repo
for chart in charts/*
do
  [ -d "$chart" ] || continue
  helm dependency build "$chart"
  helm package "$chart" --destination repo
done

if [ -f repo/index.yaml ]; then
  helm repo index --merge repo/index.yaml repo
else
  helm repo index repo
fi
