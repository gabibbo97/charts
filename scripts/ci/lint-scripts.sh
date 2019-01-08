#!/usr/bin/env sh
exec find . -type f -name "*.sh" -exec shellcheck -a -x {} \;
