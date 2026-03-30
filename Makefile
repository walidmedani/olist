.PHONY: help infra-init infra-up infra-down build up down restart logs dbt-debug dbt-run dbt-test dbt-build

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Infrastructure"
	@echo "  infra-init     Initialise Terraform"
	@echo "  infra-up       Provision GCS bucket and BigQuery dataset"
	@echo "  infra-down     Destroy all cloud infrastructure"
	@echo ""
	@echo "Docker / Airflow"
	@echo "  build          Build Docker images"
	@echo "  up             Start all services (detached)"
	@echo "  down           Stop all services"
	@echo "  restart        Rebuild and restart all services"
	@echo "  logs           Tail logs for all services"
	@echo ""
	@echo "dbt"
	@echo "  dbt-debug      Test BigQuery connection from inside the container"
	@echo "  dbt-run        Run all dbt models"
	@echo "  dbt-test       Run all dbt tests"
	@echo "  dbt-build      Run dbt models then tests (full build)"

# ── Infrastructure ────────────────────────────────────────────────────────────

infra-init:
	cd terraform && terraform init

infra-up:
	cd terraform && terraform apply -auto-approve

infra-down:
	cd terraform && terraform destroy -auto-approve

# ── Docker / Airflow ──────────────────────────────────────────────────────────

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

restart: down build up

logs:
	docker compose logs -f

# ── dbt (runs inside the scheduler container) ─────────────────────────────────

DBT_CMD = docker exec olist-de-project-airflow-scheduler-1 \
	dbt --project-dir /opt/airflow/dbt/olist --profiles-dir /opt/airflow/dbt/olist

dbt-debug:
	$(DBT_CMD) debug

dbt-run:
	$(DBT_CMD) run

dbt-test:
	$(DBT_CMD) test

dbt-build: dbt-run dbt-test
