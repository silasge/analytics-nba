# use PowerShell on windows
set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

python_dir := ".venv/Scripts"
activate := python_dir + "/activate"
python := python_dir + "/python.exe"

# Metabase stuff
metabase_url := "https://downloads.metabase.com/v0.49.5/metabase.jar"
metabase_path := "./metabase/metabase.jar"

# Duckdb driver for metabase stuff
duckdb_driver_url := "https://github.com/AlexR2D2/metabase_duckdb_driver/releases/download/0.2.6/duckdb.metabase-driver.jar"
duckdb_driver_path := "./metabase/plugins/duckdb.metabase-driver.jar"

# set up environment
bootstrap-venv VERSION="-3.11":
    @if (!(Test-Path -Path .venv)) { py {{ VERSION }} -m venv .venv }
    @{{ python }} -m pip install --upgrade uv

bootstrap-requirements:
    @{{ python }} -m uv pip sync requirements-win.txt

bootstrap:
    @just bootstrap-venv
    @just bootstrap-requirements

compile:
    @{{ python }} -m uv pip compile requirements.in -o requirements-win.txt

compile_and_sync:
    @just compile
    @just bootstrap-requirements

download:
    @{{ python }} -m nba.download

run:
    @{{ activate }}; Set-Location dbt; dbt run

query:
    @echo "Starting harlequin..."
    @{{ python }} -m harlequin -r ./data/db/nba.duckdb


download-metabase:
    @if (!(Test-Path -Path {{ metabase_path }})) \
    { Invoke-WebRequest {{ metabase_url }} -OutFile {{ metabase_path }} }

download-duckdb-driver:
    @if (!(Test-Path -Path {{ duckdb_driver_path }})) \
    { Invoke-WebRequest {{ duckdb_driver_url }} -OutFile {{ duckdb_driver_path }} }

setup-metabase:
    @just download-metabase
    @just download-duckdb-driver

run-metabase:
    @Set-Location ./metabase; java -jar metabase.jar
