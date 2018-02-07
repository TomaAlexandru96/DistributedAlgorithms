# Alexandru Toma (ait15) and Andrei Isaila (ii515)

# distributed algorithms, n.dulay, 18 jan 18
# Makefile, v1
MAIN     = System1.main
MAIN_NET = System1.main_net
PEERS = 5
MAX 	= 1000
T		  = 3000

PROJECT  = da347
NETWORK  = $(PROJECT)_network

LOCAL	 = mix run --no-halt -e $(MAIN) $(PEERS) $(MAX) $(T)
COMPOSE5 = MAIN=$(MAIN_NET) PEERS=$(PEERS) MAX=$(MAX) T=$(T) docker-compose --file docker-compose-5.yml -p $(PROJECT)
COMPOSE10 = MAIN=$(MAIN_NET) PEERS=$(PEERS) MAX=$(MAX) T=$(T) docker-compose --file docker-compose-10.yml -p $(PROJECT)

compile:
	mix compile

run:
	$(LOCAL)

clean:
	mix clean

build:
	$(COMPOSE) build

up:

	@if [ "$(PEERS)"  = "5" ]; then \
		$(COMPOSE5) up ; \
	else  \
		$(COMPOSE10) up ; \
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
