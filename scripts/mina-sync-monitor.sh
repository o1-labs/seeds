#!/usr/bin/env bash
set -e

max_attempts=40
attempt=0
status="Null"
sleep_duration=500
sync_check_command_ocaml="mina client status --json | jq -r .sync_status"
sync_check_command_rust="docker exec openmina curl -s http://localhost:3000/status | jq -r .transition_frontier.sync.status"

check_sync_status() {
  if [ "$1" == "ocaml" ]; then
    # Check if mina daemon is running
    if ! pgrep -x "mina" > /dev/null; then
      echo "Mina daemon is not running. Crashing."
      exit 1
    fi
    status=$(eval "$sync_check_command_ocaml" || echo "Null")
  elif [ "$1" == "rust" ]; then
    status=$(eval "$sync_check_command_rust" || echo "Null")
  else
    status="Null"
  fi
  echo "Current sync status: $status"
}

# Loop to check sync status
while [ $attempt -lt $max_attempts ]; do
  if [ "$1" == "ocaml" ]; then
    check_sync_status "ocaml"
  elif [ "$1" == "rust" ]; then
    check_sync_status "rust"
  else
    echo "Invalid container type. Please specify 'ocaml' or 'rust'."
    exit 1
  fi

  if [ "$status" == "Synced" ]; then
    echo "Mina client is synced."
    exit 0
  fi

  attempt=$((attempt + 1))
  echo "Mina daemon is not synced. Attempt $attempt/$max_attempts."
  sleep $sleep_duration
done

exit 1
