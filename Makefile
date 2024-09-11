# Variables
DCOMPOSE = docker-compose
DCOMPOSE_FILE = srcs/docker-compose.yml

all:
	@mkdir -p /home/$(USER)/data/mariadb/
	@mkdir -p /home/$(USER)/data/wordpress/
	$(DCOMPOSE) -f $(DCOMPOSE_FILE) up -d --build

clean:
	$(DCOMPOSE) -f $(DCOMPOSE_FILE) down --rmi all

fclean:
	$(DCOMPOSE) -f $(DCOMPOSE_FILE) down --rmi all --volumes
	docker network prune -f
	docker system prune -f
	@sudo rm -rf /home/$(USER)/data/mariadb
	@sudo rm -rf /home/$(USER)/data/wordpress

re: fclean all

.PHONY: all clean fclean re
