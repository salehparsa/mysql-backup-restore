#!/bin/bash

# Load MySQL credentials
source ./secrets.env

# Function to run query on a specific container
run_query() {
  local world=$1
  local state=$2
  local port=$3
  local container_name="mysql_world${world}_${state}"

  echo "=========================="
  echo "Results from World${world} (${state} state, port ${port}):"
  echo "=========================="

  docker exec -i $container_name mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "$QUERY" $MYSQL_DATABASE
  echo ""
}

# Check if query is provided
if [ -z "$1" ]; then
  echo "Usage: $0 \"<query>\""
  exit 1
fi

QUERY=$1

# Run query on all databases
for world in $(seq 1 $NUM_WORLDS); do
  run_query $world "before" "330${world}"
  run_query $world "after" "330${world}${world}"
done
