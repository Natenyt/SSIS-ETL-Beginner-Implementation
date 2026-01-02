# Script to check databases in SQL Server Docker container
# Usage: .\check-databases.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Checking Databases in SQL Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if container is running
$containerStatus = docker ps --filter "name=sqlserver-etl" --format "{{.Status}}"
if (-not $containerStatus) {
    Write-Host "ERROR: SQL Server container is not running!" -ForegroundColor Red
    Write-Host "Start it with: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "Container Status: $containerStatus" -ForegroundColor Green
Write-Host ""

# Query databases
Write-Host "Querying databases..." -ForegroundColor Yellow
Write-Host ""

$query = 'SELECT name AS DatabaseName, database_id AS ID, create_date AS CreatedDate FROM sys.databases ORDER BY name'

docker exec sqlserver-etl bash -c "/opt/mssql-tools*/bin/sqlcmd -S localhost -U sa -P YourStrong@Pass123 -C -Q '$query' -W -h -1"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Query completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to query databases" -ForegroundColor Red
}

