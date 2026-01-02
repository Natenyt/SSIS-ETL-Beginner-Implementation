# Quick Start Script for SQL Server on Docker
# Run this script to start SQL Server container

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting SQL Server on Docker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not installed or not running!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Check if Docker Compose is available
Write-Host "Checking Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version
    Write-Host "Docker Compose found: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker Compose is not available!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Starting SQL Server container..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SQL Server is starting..." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Connection Details:" -ForegroundColor Cyan
    Write-Host "  Server: localhost or localhost,1433" -ForegroundColor White
    Write-Host "  Authentication: SQL Server Authentication" -ForegroundColor White
    Write-Host "  Login: sa" -ForegroundColor White
    Write-Host "  Password: YourStrong@Password123" -ForegroundColor White
    Write-Host ""
    Write-Host "Waiting for SQL Server to be ready (this may take 30-60 seconds)..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To check status, run: docker ps" -ForegroundColor Cyan
    Write-Host "To view logs, run: docker-compose logs -f sqlserver" -ForegroundColor Cyan
    Write-Host "To stop, run: docker-compose down" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to start SQL Server container!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Yellow
}

