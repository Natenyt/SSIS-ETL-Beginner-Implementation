# SQL Server on Docker - Setup Guide

## Overview
This guide will help you set up SQL Server using Docker, which is much easier than installing SQL Server directly on Windows.

## Prerequisites

### 1. Install Docker Desktop
1. Download Docker Desktop for Windows:
   - https://www.docker.com/products/docker-desktop/
   - Or: https://docs.docker.com/desktop/install/windows-install/

2. Install Docker Desktop:
   - Run the installer
   - Follow the installation wizard
   - Restart your computer if prompted

3. Verify Docker is running:
   - Open Docker Desktop
   - Wait for it to start (whale icon in system tray)
   - Open Command Prompt or PowerShell
   - Run: `docker --version`
   - You should see Docker version information

### 2. Install Docker Compose
- Docker Compose is usually included with Docker Desktop
- Verify: Run `docker-compose --version` in Command Prompt

## Quick Start

### Step 1: Start SQL Server Container

1. Open Command Prompt or PowerShell in the project directory
2. Run:
   ```bash
   docker-compose up -d
   ```

3. Wait for the container to start (30-60 seconds)
4. Verify it's running:
   ```bash
   docker ps
   ```
   You should see `sqlserver-etl` container running

### Step 2: Connect to SQL Server in SSMS

1. Open **SQL Server Management Studio (SSMS)**
2. In the connection dialog:
   - **Server name**: `localhost,1433` or `localhost`
   - **Authentication**: SQL Server Authentication
   - **Login**: `sa`
   - **Password**: `971412811`
3. Click **Connect**

### Step 3: Create Database and Tables

1. In SSMS, click **New Query**
2. Run the `products.sql` script to create the Products table
3. Run the `CreateProcessedTransactionsTable.sql` script to create the destination table

Or use Docker to run SQL scripts:

```bash
# Run products.sql
docker exec -i sqlserver-etl /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Password123 -d master -i /sql_scripts/products.sql

# Run CreateProcessedTransactionsTable.sql
docker exec -i sqlserver-etl /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Password123 -d master -i /sql_scripts/CreateProcessedTransactionsTable.sql
```

## Docker Commands Reference

### Start SQL Server
```bash
docker-compose up -d
```

### Stop SQL Server
```bash
docker-compose down
```

### Stop SQL Server (keep data)
```bash
docker-compose stop
```

### View Logs
```bash
docker-compose logs -f sqlserver
```

### Check Container Status
```bash
docker ps
```

### Execute SQL Command
```bash
docker exec -it sqlserver-etl /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Password123
```

### Backup Database
```bash
docker exec sqlserver-etl /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Password123 -Q "BACKUP DATABASE [YourDB] TO DISK = '/var/opt/mssql/backup/YourDB.bak'"
```

## Configuration

### Change Password
Edit `docker-compose.yml` and change:
```yaml
- MSSQL_SA_PASSWORD=YourStrong@Password123
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

### Change Port
If port 1433 is already in use, change in `docker-compose.yml`:
```yaml
ports:
  - "1434:1433"  # Use 1434 instead of 1433
```

Then connect with: `localhost,1434`

### Access SQL Scripts
SQL scripts in the `sql_scripts` folder are mounted to `/sql_scripts` in the container.

## Troubleshooting

### Problem: Docker Desktop not starting
**Solution:**
- Ensure virtualization is enabled in BIOS
- Check Windows Features: Enable "Hyper-V" or "Windows Subsystem for Linux"
- Restart Docker Desktop

### Problem: Port 1433 already in use
**Solution:**
- Change port in `docker-compose.yml` (see Configuration section)
- Or stop any existing SQL Server services:
  ```bash
  # In Services (services.msc), stop SQL Server services
  ```

### Problem: Cannot connect to SQL Server
**Solution:**
1. Check container is running: `docker ps`
2. Check logs: `docker-compose logs sqlserver`
3. Wait a bit longer (SQL Server takes time to start)
4. Verify password is correct: `YourStrong@Password123`

### Problem: Container keeps restarting
**Solution:**
- Check logs: `docker-compose logs sqlserver`
- Verify password meets requirements (8+ chars, uppercase, lowercase, number, special char)
- Check Docker has enough resources allocated

## Data Persistence

Data is stored in a Docker volume named `sqlserver_data`. This means:
- Data persists even if you stop the container
- Data is removed only if you run `docker-compose down -v`

To backup your data:
```bash
docker exec sqlserver-etl /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Password123 -Q "BACKUP DATABASE [YourDB] TO DISK = '/var/opt/mssql/backup/YourDB.bak'"
```

## Next Steps

1. ✅ Start SQL Server: `docker-compose up -d`
2. ✅ Connect in SSMS: `localhost` with `sa` / `YourStrong@Password123`
3. ✅ Create database and tables
4. ✅ Proceed with SSIS package creation

## Advantages of Docker Approach

- ✅ No complex SQL Server installation
- ✅ Easy to start/stop
- ✅ Isolated environment
- ✅ Easy to reset (just remove container)
- ✅ Works on any OS with Docker
- ✅ No conflicts with other SQL Server installations

---

**Note**: For SSIS, you'll still need Visual Studio with SSDT installed on your Windows machine. Docker only provides the SQL Server database engine.

