#!/bin/sh
set -e # Fail on error

# Create Helm repo dir
rm -rf repo && mkdir repo

# Limit parallelism
MAX_JOBS=1 #$(nproc)
JOBS=""

# Iterate over commits
for commit in $(git rev-list --reverse HEAD -- 'charts/*/Chart.yaml'); do
    # Process commit
    printf "Processing commit: %s\n" "$commit"

    # Parse which charts did change
    (
        # Copy current folder to temporary folder
        TEMPDIR=$(mktemp -d)
        cp -ra "$PWD/." "$TEMPDIR"

        # Checkout folder
        (cd "$TEMPDIR" && git checkout -q "$commit")

        # Package charts
        git ls-tree --name-only -r "$commit" \
            | grep -E '^charts/[^/]+/Chart\.yaml' \
            | xargs dirname \
            | sed -e 's|charts/||' \
            | while read -r chartName; do

            # Build chart
            helm dependency build "$TEMPDIR/charts/$chartName"
            helm package "$TEMPDIR/charts/$chartName" --destination "$PWD/repo"
        done

        # Cleanup
        rm -rf "$TEMPDIR"
    ) &
    JOBS="${JOBS} $!"

    # Wait if too many jobs
    if [ "$(echo $JOBS | wc -w)" = "$MAX_JOBS" ]; then
        for job in $JOBS; do wait "$job"; done
        JOBS=""
    fi
done

# Wait for jobs
if [ "$(echo $JOBS | wc -w)" != "$0" ]; then
    for job in $JOBS; do wait "$job"; done
    JOBS=""
fi

helm repo index ./repo
echo 'Built index'
