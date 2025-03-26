all: build run

data:
	@if [ ! -f "./srcs/.env" ]; then \
		echo "file .env not found. Creating..."; \
		echo "file .env created."; \
		cat ./secrets/credentials.txt > ./srcs/.env; \
		cat ./secrets/db.txt >> ./srcs/.env; \
		cat ./secrets/site.txt >> ./srcs/.env; \
	fi
	
	@if [ ! -d "/home/vivaccar/data/mariadb" ]; then \
    	mkdir -p /home/vivaccar/data/mariadb; \
	fi

	@if [ ! -d "/home/vivaccar/data/wordpress" ]; then \
    	mkdir -p /home/vivaccar/data/wordpress; \
	fi

build: data
	docker compose -f srcs/docker-compose.yml build --no-cache

run:
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

imgclean:
	docker compose -f srcs/docker-compose.yml down --rmi all

volclean:
	docker compose -f srcs/docker-compose.yml down --rmi all -v

fclean: volclean
	docker system prune -af

dls:
	docker ps -a

vls:
	docker volume ls

ils:
	docker image ls

nls:
	docker network ls

.SILENT:
