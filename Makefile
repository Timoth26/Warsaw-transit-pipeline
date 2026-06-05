SHELL := /bin/bash

COMPOSE := docker compose -f docker-compose.yml
DBT_DIR := dbt/warsaw_transit_dbt
DBT := cd $(DBT_DIR) && dbt

up:
	docker compose -f docker-compose.yml up -d

down:
	docker compose -f docker-compose.yml down

restart:
	docker compose -f docker-compose.yml down
	docker compose -f docker-compose.yml up -d

clean:
	docker compose -f docker-compose.yml down -v --remove-orphans

dbt-docs:
	$(DBT) docs generate && \
	$(DBT) docs serve

dbt-list-models:
	$(DBT) ls --resource-type model
