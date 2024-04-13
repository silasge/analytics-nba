$python_dir = ".\.venv\Scripts"
$activate = $python_dir + "\activate"
$python = $python_dir + "\python.exe"

function Install-VirtualEnvironment {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Version = 3.11
    )

    if (!(Test-Path -Path .venv)) {
        Invoke-Expression "py -$Version -m venv .venv"
    } else {
        Write-Host "Python virtual enviromnent $Version already installed."
    }

    Invoke-Expression "$python -m pip install uv"
    Invoke-Expression "$python -m uv pip sync requirements.txt"
}

function Update-Dependences {
    Invoke-Expression "$python -m uv pip compile requirements.in -o requirements.txt"
}

function Get-NBAData {
    Invoke-Expression "$python -m nba.download"
}

function Invoke-DBT {
    Invoke-Expression $activate
    Set-Location .\dbt\
    dbt run
    Set-Location ..
    deactivate
}

function Query-DB {
    Write-Host "Starting harlequin..."
    Invoke-Expression "$python -m harlequin -r .\data\db\nba.duckdb"
}

function Get-Metabase {
    if (!(Test-Path -Path .\metabase\metabase.jar)) {
        $metabase_url = "https://downloads.metabase.com/v0.49.5/metabase.jar"
        Invoke-WebRequest $metabase_url -OutFile .\metabase\metabase.jar
    } else {
        Write-Host "metabase.jar already exists. Skipping download."
    }

    if (!(Test-Path -Path .\metabase\plugins\duckdb.metabase-driver.jar)) {
        $duckdb_driver = "https://github.com/AlexR2D2/metabase_duckdb_driver/releases/download/0.2.6/duckdb.metabase-driver.jar"

        Invoke-WebRequest $duckdb_driver -OutFile .\metabase\plugins\duckdb.metabase-driver.jar
    } else {
        Write-Host "Duckdb driver already installed. Skipping download."
    }
}

function Open-Metabase {
    Set-Location .\metabase
    java -jar metabase.jar
}

function Invoke-All {
    Get-NBAData
    Invoke-DBT
    Get-Metabase
}
