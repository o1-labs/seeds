#!/usr/bin/env bash
set -e

max_attempts=40
attempt=0
status="Null"
sleep_duration=500
sync_check_command="docker exec openmina curl -s http://localhost:3000/status | jq -r .transition_frontier.sync.status"

check_sync_status() {
  status=$(eval "$sync_check_command" || echo "Null")
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
