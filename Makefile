.PHONY: dbt

PYTHON_DIR := ./.venv/bin
ACTIVATE := ${PYTHON_DIR}/activate
PYTHON := ${PYTHON_DIR}/python

bootstrap-venv:
	@if ! [ -d .venv ]; then python3 -m venv .venv; fi

bootstrap-uv:
	@${PYTHON} -m pip install uv

bootstrap-requirements:
	@${PYTHON} -m uv pip sync linux-requirements.txt

bootstrap: bootstrap-venv bootstrap-uv bootstrap-requirements

compile:
	@${PYTHON} -m uv pip compile requirements.in -o linux-requirements.txt

compile-and-sync: compile bootstrap

download:
	@echo "Downloading nba data..."
	@${PYTHON} -m nba.download

dbt:
	@echo "Running DBT Models..."
	@. ${ACTIVATE} && cd dbt && dbt run

query:
	@echo "Starting harlquin..."
	@${PYTHON} -m harlequin -r ./data/db/nba.duckdb

