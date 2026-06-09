SHELL := /bin/bash

DBT_DIR := dbt/warsaw_transit_dbt
SUPERSET_DIR := superset
DBT := cd $(DBT_DIR) && dbt

airflow-up:
	docker compose -f docker-compose.yml up -d

airflow-down:
	docker compose -f docker-compose.yml down

airflow-restart:
	docker compose -f docker-compose.yml down
	docker compose -f docker-compose.yml up -d

clean:
	docker compose -f docker-compose.yml down -v --remove-orphans

dbt-docs:
	$(DBT) docs generate && \
	$(DBT) docs serve

dbt-list-models:
	$(DBT) ls --resource-type model

superset-up:
	docker compose -f $(SUPERSET_DIR)/docker-compose.yml up -d

superset-down:
	docker compose -f $(SUPERSET_DIR)/docker-compose.yml down

superset-restart:
	docker compose -f $(SUPERSET_DIR)/docker-compose.yml down
	docker compose -f $(SUPERSET_DIR)/docker-compose.yml up -d
