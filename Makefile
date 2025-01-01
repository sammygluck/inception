all: dep
	sudo docker-compose -f srcs/docker-compose.yml up -d

re: dep 
	sudo docker-compose -f srcs/docker-compose.yml up -d --build 

clean:
	sudo docker-compose -f srcs/docker-compose.yml down --rmi all -v

reset:
	sudo bash srcs/requirements/tools/reset.sh

dep:
	mkdir -p /home/sgluck/data/mariadb_data
	mkdir -p /home/sgluck/data/wordpress_data

.PHONY: all docker dep clean reset
