#!/bin/sh
set -e # Fail on error

if [ -f /tmp/server-started ]; then
  # Already started
  exit 0
fi

# Check logs
if ! [ -f logs/latest.log ]; then
  echo 'Log file not found'
  exit 1
fi

# Try latest log
if grep 'Done' < logs/latest.log | grep -E '[0-9]+'; then
  touch /tmp/server-started
  exit 0
fi

# Try older logs
if [ -d logs ]; then
  for logfile in logs/*.gz ; do
    [ -f "$logfile" ] || continue
    if zcat "$logfile" | grep 'Done' | grep -E '[0-9]+'; then
      touch /tmp/server-started
      exit 0
    fi
  done
fi

exit 1
