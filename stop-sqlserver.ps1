# Stop SQL Server Docker Container
# Run this script to stop SQL Server container

Write-Host "Stopping SQL Server container..." -ForegroundColor Yellow
docker-compose down

if ($LASTEXITCODE -eq 0) {
    Write-Host "SQL Server container stopped." -ForegroundColor Green
} else {
    Write-Host "Error stopping container." -ForegroundColor Red
}

