# Multiple Database Restoration and Query System

This project provides a system for restoring and querying MySQL databases from backup files. It would be useful to have it for troubleshooting propose when you want to run multiple MySQL instances locally and restore backup

## Prerequisites

- Docker
- Docker Compose
- Python 3
- `pip` package manager

## Setup

### Install Python dependencies

Ensure you have the `jinja2` package installed in your Python environment:

```bash
pip install jinja2
```

### Prepare the Environment Files

Create a `secrets.env` file with your MySQL credentials:

```
MYSQL_DATABASE=database
MYSQL_PASSWORD=password
```
A sample of `secrets.env` available in the repository.

Create a `backups.env` file specifying the backup files for each database and state:

```bash
world1_before_backup=backup1_before.sql.gz
world1_after_backup=backup1_after.sql.gz
world2_before_backup=backup2_before.sql.gz
world2_after_backup=backup2_after.sql.gz
world3_before_backup=backup3_before.sql.gz
world3_after_backup=backup3_after.sql.gz
```
In our example, each world has a state before and after. Please note that the state before and after needs to be in lower case. In the `backups.env` which is available in the repository I used my backup name, but in general you can add yours and there is no limitation there since it's just an environmental variable

## Generate and Run Docker Compose

This project is using a template to generate a `docker-compose.yml` depends on the amount of databases that you need. The assumption here is you need to have two database per service and use one of them for the data belongs to prior to the incident and the other one for with the backup of the data after the incident. You are able to use the `Makefile` to generate the `docker-compose.yml` file and start the Docker services:

```bash
make NUM_WORLDS=3 up
```
Above going to create a `docker-compose.yml` with 6 MySQL databases for 3 different services and bring them up. The `docker-compose.yml` in the repository is also generated based on this make target.

## Restore Backups on all databases at once

This project contains a script `restore-backup.sh` that restore all the backups to the databases. You can run this script with the following target:

```bash
make NUM_WORLDS=3 restore
```
## Restore Backup on single database

You are able to restore one backup with executing following:

```bash
docker exec -i CONTAINER_NAME sh -c 'exec mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE'
```

Please replace the `CONTAINER_NAME` with the name of the container that you want to restore the backup on.

## Running query against all databases

We do have a script in this repository `run-query.sh` which helps you to run the single query against all databases and show the result of them. You can run it via following target:

```bash
make NUM_WORLDS=3 query QUERY="SELECT 1"
```

## Running query against one database

In general you can easily execute a query against a single database. You can run following:
```bash
docker exec -i mysql_world1_after mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "select * FROM game.player;"
```

## Stop Services
You can easily stop the containers via following targets:
```bash
make NUM_WORLDS=3 make down
```
Please note, when you need 3 services you don't need to add `NUM_WORLDS=3` for make targets since it has the default values already

## Files and Directories

```
project-root/
├── backups/
│   ├── world1/
│   │   ├── backup1_before.sql.gz
│   │   ├── backup1_after.sql.gz
│   ├── world2/
│   │   ├── backup2_before.sql.gz
│   │   ├── backup2_after.sql.gz
│   ├── world3/
│   │   ├── backup3_before.sql.gz
│   │   ├── backup3_after.sql.gz
├── docker/
│   ├── Dockerfile
├── scripts/
│   ├── restore_backups.sh
│   ├── run-query.sh
├── secrets.env
├── backups.env
├── Makefile
├── docker-compose.template.yml
├── README.md
```
## Files overview
`Makefile`: Defines the build and run automation tasks.
`docker-compose.template.yml`: The Jinja2 template for generating `docker-compose.yml`.
`/scripts/restore-backup.sh`: The script to restore backups into MySQL containers.
`/scripts/run-query.sh`: The script to run a query against all MySQL databases.
`secrets.env`: Environment file containing MySQL credentials.
`backups.env`: Environment file specifying the backup files for each database and state.

## Notes
Ensure the backup files are placed in the appropriate directories as specified in `backups.env`.
Adjust the number of worlds by setting the `NUM_WORLDS` variable when running make commands.
Right now if you have `NUM_WORLDS=3` and have `docker-compose.yml` for that and wants to have more services lets say `NUM_WORLDS=6` you need to remove the old `docker-compose.yml` first and let the make target recreate it with the new value.


## Troubleshooting
If you encounter any issues, please ensure that:

Docker and Docker Compose are installed and running.
The environment files (`secrets.env` and `backups.env`) are correctly configured.
Backup files are placed in the appropriate directories.
