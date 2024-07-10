# Define the default number of worlds
NUM_WORLDS ?= 3

# Read secrets.env and export the variables
include secrets.env
export $(shell sed 's/=.*//' secrets.env)

# Generate the docker-compose.yml from the template
docker-compose.yml: docker-compose.template.yml
	@echo "Generating docker-compose.yml with $(NUM_WORLDS) worlds..."
	@python3 -c "import jinja2, os; template = jinja2.Template(open('docker-compose.template.yml').read()); print(template.render(num_worlds=int(os.environ['NUM_WORLDS'])))" > docker-compose.yml

# Bring up the Docker Compose stack
up: docker-compose.yml
	docker compose up -d

# Bring down the Docker Compose stack
down:
	docker compose down

# Restart the Docker Compose stack
restart: down up

# Restore Backup
restore:
	NUM_WORLDS=$(NUM_WORLDS) ./scripts/restore-backup.sh

# Run query against all databases
query:
	@NUM_WORLDS=$(NUM_WORLDS) ./scripts/run-query.sh "$(QUERY)"


.PHONY: up down restart
