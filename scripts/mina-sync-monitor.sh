#!/usr/bin/env bash
# filepath: /Users/sanabriarusso/github/seeds/scripts/mina-sync-monitor-fixed.sh
set -e

max_attempts=10
attempt=0
status="Null"
sleep_duration=300
is_daemon_running="mina client status"
# Modified command to store raw output first, then parse it safely
sync_check_command_ocaml="mina client status --json"
sync_check_command_rust="docker exec openmina curl -s http://localhost:3000/status | jq -r .transition_frontier.sync.status"

check_sync_status() {
  if [ "$1" == "ocaml" ]; then
    # Check if mina daemon is running
    if ! pgrep -x "mina" > /dev/null; then
      echo "Mina daemon is not running. Crashing."
      exit 1
    fi
    
    # First, capture the raw output
    raw_output=$(eval "$sync_check_command_ocaml" 2>&1 || echo "")
    
    # Check if output exists and can be parsed
    if [ -z "$raw_output" ]; then
      echo "Error: Empty response from mina client status"
      status="Null"
    elif ! echo "$raw_output" | jq . &>/dev/null; then
      echo "Error: Invalid JSON from mina client status"
      echo "Raw output: $raw_output"
      status="Null"
    else
      # If JSON is valid, extract the sync_status
      status=$(echo "$raw_output" | jq -r '.sync_status // "Null"')
    fi
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

echo "Failed to sync after $max_attempts attempts."
exit 1
