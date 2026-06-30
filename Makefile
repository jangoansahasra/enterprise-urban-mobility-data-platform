.PHONY: help install start-db stop-db schema views profile validate transform etl load-sample load-full quality test api train train-pretrip

help:
	@echo "Available commands:"
	@echo "  make install        Install Python dependencies"
	@echo "  make start-db       Start PostgreSQL with Docker Compose"
	@echo "  make stop-db        Stop Docker Compose services"
	@echo "  make schema         Apply schema, seed tables, indexes, and views"
	@echo "  make profile        Run raw data profiling"
	@echo "  make validate       Run raw data validation"
	@echo "  make transform      Run taxi data transformation"
	@echo "  make etl            Run profiling, validation, and transformation"
	@echo "  make load-sample    Load 100,000 rows into PostgreSQL"
	@echo "  make load-full      Load full cleaned dataset into PostgreSQL"
	@echo "  make views          Apply SQL analytics views"
	@echo "  make quality        Run SQL data quality checks"
	@echo "  make test           Run pytest"
	@echo "  make api            Start FastAPI server"
	@echo "  make train          Train analytical trip duration model"
	@echo "  make train-pretrip  Train pre-trip duration model"

install:
	python -m pip install -r requirements.txt

start-db:
	docker compose up -d

stop-db:
	docker compose down

schema:
	docker exec -i urban_mobility_postgres psql -U urban_user -d urban_mobility_db < database/schema.sql
	docker exec -i urban_mobility_postgres psql -U urban_user -d urban_mobility_db < database/seed_reference_tables.sql
	docker exec -i urban_mobility_postgres psql -U urban_user -d urban_mobility_db < database/indexes.sql
	docker exec -i urban_mobility_postgres psql -U urban_user -d urban_mobility_db < sql/analytics_views.sql

views:
	docker exec -i urban_mobility_postgres psql -U urban_user -d urban_mobility_db < sql/analytics_views.sql

profile:
	python -m etl.profile.profile_raw_data

validate:
	python -m etl.validate.validate_taxi_data

transform:
	python -m etl.transform.transform_taxi_data

etl:
	python -m etl.pipeline

load-sample:
	python -m etl.load.load_to_postgres

load-full:
	LOAD_SAMPLE_SIZE=0 python -m etl.load.load_to_postgres

quality:
	docker exec -i urban_mobility_postgres psql -U urban_user -d urban_mobility_db < sql/data_quality_checks.sql

test:
	python -m pytest

api:
	python -m uvicorn api.main:app --reload

train:
	python -m ml.train_model

train-pretrip:
	python -m ml.train_pretrip_model