#!/usr/bin/env bash
set -e
max_attempts=40
attempt=0
sleep_duration=500
status="Null"

check_sync_status() {
  status=$(docker exec mina mina client status --json | jq -r .sync_status || echo "Null")
  echo "Current sync status: $status"
}

# Loop to check sync status
while [ $attempt -lt $max_attempts ]; do
  check_sync_status
  if [ "$status" == "Synced" ]; then
    echo "Mina client is synced."
    exit 0
  fi

  attempt=$((attempt + 1))

  echo "Mina daemon is not synced. Attempt $attempt/$max_attempts."
  sleep $sleep_duration
done

exit 1
