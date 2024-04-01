#!/usr/bin/env bash
set -e
seed_list="${1:-seeds.txt}"
exit_code=0

check_seed () {
  seed="$1"
  host=$(echo "$seed" | cut -d '/' -f3)
  port=$(echo "$seed" | cut -d '/' -f5)

  if timeout 1 nc -z "$host" "$port" 1>/dev/null 2>&1; then
    echo "$seed: ONLINE"
  else
    echo "$seed: OFFLINE"
    exit_code=1
  fi
}

while read -r seed; do
  check_seed "$seed"
done < "$seed_list"

exit "$exit_code"
