#!/usr/bin/env sh

set -e

git clone https://github.com/gabibbo97/charts.git old-repo

for commit in $(git rev-list origin); do
  if git ls-tree --name-only -r "$commit" | grep -q 'Chart.yaml'; then
    printf 'Commit: %s\n' "$commit"

    mkdir -p repo

    (
      cd old-repo
      git checkout "$commit"
    )

    find old-repo/charts/ -mindepth 1 -maxdepth 1  -type d -exec helm dependency build {} \;
    find old-repo/charts/ -mindepth 1 -maxdepth 1  -type d -exec helm package --destination repo {} \;
    helm repo index --merge repo/index.yaml repo
  else
    continue
  fi
done

rm -rf old-repo