all: dep
	@echo "Creating and running the Docker containers..."
	@sudo docker-compose -f srcs/docker-compose.yml up -d

re: dep 
	@echo "Rebuilding and running the Docker containers..."
	@sudo docker-compose -f srcs/docker-compose.yml up -d --build 

clean:
	@echo "Stopping and removing Docker containers, images and volumes..."
	@sudo docker-compose -f srcs/docker-compose.yml down --rmi all -v

reset:
	@echo "Performing a full reset of the Docker environment..."
	@sudo bash srcs/requirements/tools/reset.sh

dep:	
	@echo "Creating mariadb persistent volume at /home/sgluck/data/mariadb_data..."
	@mkdir -p /home/sgluck/data/mariadb_data
	@echo "Creating WordPress persistent volume at /home/sgluck/data/wordpress_data..."
	@mkdir -p /home/sgluck/data/wordpress_data
	@echo "Checking if necessary to add host to /etc/hosts file"
	@./srcs/requirements/tools/add_host_entry.sh

.PHONY: all docker dep clean reset
