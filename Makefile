DOCKER_COMPOSE = docker compose
COMPOSE_FILE = ./srcs/docker-compose.yml
NAME = inception
VOLUME_PATH = /home/dahmane/data

# --- MAIN TARGETS ---
all: build up

# Builds or re-builds all services without starting them.
build:
	@echo "🛠️ Building Docker images..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build

# Starts the services (assumes images are built).
up:
	@echo "🚀 Starting containers in detached mode..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d

# Stops, removes, builds, and restarts the containers.
# Use this when you change a Dockerfile or configuration.
re rebuild: down build up

# --- LIFECYCLE MANAGEMENT ---
# Stops the running containers without removing them.
stop:
	@echo "🛑 Stopping containers..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) stop

# Stops and removes containers, networks, and volumes.
down:
	@echo "🗑️ Removing containers, networks, and volumes..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down --rmi all -v

# Alias for 'down' to remove everything.
clean: down

# Follows the logs of all services.
logs:
	@echo "📖 Following container logs..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f

# --- UTILITY TARGETS ---
# Lists the status of all running containers.
ps:
	@echo "📋 Listing container status..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

# Stops, removes all containers + volumes
fclean: clean
	@echo "🧹 Cleaning up volumes..."
	docker volume prune -f
	@sudo rm -rf $(VOLUME_PATH)/wordpress/*
	@sudo rm -rf $(VOLUME_PATH)/mariadb/*

# --- HELPER TARGETS ---
# Access the NGINX container shell
shell-nginx:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec nginx sh

# Access the WORDPRESS container shell
shell-wordpress:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec wordpress sh

# Access the MARIADB container shell
shell-mariadb:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec mariadb sh
	
.PHONY: all build up re rebuild stop down clean logs ps fclean shell-nginx shell-wordpress shell-mariadb