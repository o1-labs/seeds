#!/usr/bin/env bash

# Start Mina Daemon in background and redirect output
nohup openmina node --peers "$1" > openmina.log 2>&1 &
DAEMON_PID=$!

# Give it some time to initialize
echo "Started openmina with PID: $DAEMON_PID"
echo "Waiting for daemon to initialize..."
sleep 10

# Check if process is still running
if ps -p $DAEMON_PID > /dev/null; then
  echo "Openmina daemon running with PID: $DAEMON_PID"
  # Try to check if API is responsive
  MAX_ATTEMPTS=5
  ATTEMPT=0
  while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo "Checking API connectivity (attempt $ATTEMPT/$MAX_ATTEMPTS)..."
    if curl -s http://localhost:3000/status &> /dev/null; then
      echo "API is responding. Daemon started successfully."
      exit 0
    fi
    sleep 5
  done
  echo "API did not respond within timeout, but process is running. Continuing..."
  exit 0
else
  echo "Error: Openmina daemon failed to start or terminated prematurely"
  cat openmina.log || echo "No log file found"
  exit 1
fi
