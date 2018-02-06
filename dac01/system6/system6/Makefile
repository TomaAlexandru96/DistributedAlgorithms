#/bin/sh
# distributed algorithms, n.dulay, 18 jan 18
# Makefile, v1
PEERS = 5
MAIN     = System1.main

PROJECT  = da347
NETWORK  = $(PROJECT)_network

LOCAL	 = mix run --no-halt -e $(MAIN)
COMPOSE5 = MAIN=$(MAIN)  docker-compose --file docker-compose-5.yml -p $(PROJECT)
COMPOSE10 = MAIN=$(MAIN)  docker-compose --file docker-compose-10.yml -p $(PROJECT)

compile:
	mix compile

run:
	$(LOCAL)

clean:
	mix clean

build:
	$(COMPOSE) build

up:
	@if [ "$(MAIN)"  = "Tests.test3_net" ]; then \
		$(COMPOSE10) up ; \
	else \
		$(COMPOSE5) up ; \
	fi
down:
	$(COMPOSE) down
	make show

show:
	@echo ----------------------
	@make ps
	@echo ----------------------
	@make network

show2:
	@echo ----------------------
	@make ps2
	@echo ----------------------
	@make network

ps:
	docker ps -a --format 'table {{.Names}}\t{{.Image}}'

ps2:
	docker ps -a -s

network net:
	docker network ls

inspect:
	docker network inspect $(NETWORK)

netrm:
	docker network rm $(NETWORK)
conrm:
	docker rm $(ID)

kill:
	docker rm -f `docker ps -a -q`
	docker network rm $(NETWORK)
