# use PowerShell on windows
set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

python_dir := ".venv/Scripts"
activate := python_dir + "/activate"
python := python_dir + "/python.exe"

# set up environment
bootstrap VERSION="-3.11":
    @if (!(Test-Path -Path .venv)) { py {{ VERSION }} -m venv .venv }
    @{{ python }} -m pip install --upgrade uv
    @{{ python }} -m uv pip sync requirements.txt

upgrade-deps: && bootstrap
    @{{ python }} -m uv pip compile requirements.in -o requirements.txt

download:
    @{{ python }} -m nba.download

run:
    @{{ activate }} && cd dbt && dbt run

query:
    @echo "Starting harlequin..."
    @{{ python }} -m harlequin ./data/db/nba.duckdb

clean:
    @rm ./data/db/nba.duckdb
