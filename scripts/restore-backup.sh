#!/bin/bash

set -e

# Load environment variables
source ./backups.env
source ./secrets.env

# Function to restore a backup for a specific world
restore_backup() {
  local world=$1
  local state=$(echo $2 | tr '[:upper:]' '[:lower:]')
  local backup_file_var="WORLD${world}_${state}_BACKUP"
  local backup_file=${!backup_file_var}
  local container_name="mysql_world${world}_${state}"

  if [ -z "$backup_file" ]; then
    echo "Backup file for World${world} is not specified in the environment file."
    exit 1
  fi

  local backup_path="./backups/world${world}/${backup_file}"

  if [ -f "$backup_path" ]; then
    echo "Restoring backup for World${world} ($state) from $(basename $backup_path)..."
    gunzip -c "$backup_path" | docker exec -i $container_name sh -c 'exec mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE'
  else
    echo "Backup file $backup_path not found for World${world} ($state)."
    exit 1
  fi
}

# Sleep to ensure MySQL containers are fully up
# This might be good candidate for improvement later by adding a wait script that wait for docker host to be up and running
sleep 15

# Restore backups for all worlds
for world in $(seq 1 $NUM_WORLDS); do
  restore_backup $world "BEFORE"
  restore_backup $world "AFTER"
done

echo "All backups restored."
