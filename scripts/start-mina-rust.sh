#!/usr/bin/env bash

# Start Mina Rust daemon in background and redirect output
nohup mina node --verbosity=info --peers "$1" > mina-rust.log 2>&1 &
DAEMON_PID=$!

# Give it some time to initialize
echo "Started Mina Rust daemon with PID: $DAEMON_PID"
echo "Waiting for daemon to initialize..."
sleep 10

# Check if process is still running
if ps -p $DAEMON_PID > /dev/null; then
  echo "Mina Rust daemon running with PID: $DAEMON_PID"
  # Try to check if API is responsive
  MAX_ATTEMPTS=5
  ATTEMPT=0
  while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo "Checking API connectivity (attempt $ATTEMPT/$MAX_ATTEMPTS)..."
    API_RESPONSE=$(curl -s http://localhost:3000/status)
    if [ -n "$API_RESPONSE" ] && [ "$API_RESPONSE" != "null" ]; then
      echo "API is responding. Daemon started successfully."
      echo "API Response: $API_RESPONSE"
      # Also show sync status specifically
      SYNC_STATUS=$(echo "$API_RESPONSE" | jq -r '.transition_frontier.sync.status' 2>/dev/null || echo "Could not parse sync status")
      echo "Current Sync Status: $SYNC_STATUS"
      exit 0
    fi
    sleep 5
  done
  echo "API did not respond within timeout, but process is running. Continuing..."
  exit 0
else
  echo "Error: Mina Rust daemon failed to start or terminated prematurely"
  cat mina-rust.log || echo "No log file found"
  exit 1
fi
