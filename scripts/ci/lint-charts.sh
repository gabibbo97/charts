#!/usr/bin/env sh
for chart in charts/*
do
  [ -d "$chart" ] || continue
  helm lint --strict "$chart"
done
