# SSIS ETL Assignment - Implementation Package

## Overview
This package contains all necessary files and documentation for implementing an ETL process using SQL Server Integration Services (SSIS) to extract, transform, and load data from multiple sources.

## Project Structure

```
Assignment4/
│
├── docker-compose.yml             # Docker Compose configuration for SQL Server
├── .dockerignore                  # Docker ignore file
│
├── Data Sources/
│   ├── transactions.csv          # CSV file with transaction data
│   ├── customers.xlsx             # Excel file with customer data
│   └── products.sql               # SQL script to create Products table
│
├── sql_scripts/                   # SQL scripts folder (mounted in Docker)
│   ├── products.sql               # Create and populate Products table
│   └── CreateProcessedTransactionsTable.sql  # Create destination table
│
├── SQL Scripts/
│   ├── products.sql               # Create and populate Products table
│   ├── CreateProcessedTransactionsTable.sql  # Create destination table
│   └── ValidationQueries.sql      # Data validation queries
│
├── Documentation/
│   ├── README.md                  # This file
│   ├── Docker_Setup_Guide.md      # Docker setup instructions
│   ├── ETL_Implementation_Guide.md  # Step-by-step SSIS implementation guide
│   └── ETL_Process_Report.md      # Comprehensive process documentation
│
└── SSIS Package/
    └── [To be created in Visual Studio]  # SSIS .dtsx package file
```

## ⚠️ IMPORTANT: Setup First!

**Before starting, make sure you have all required tools installed!**

### 🐳 **RECOMMENDED: Use Docker for SQL Server** (Easiest Method)

1. **Install Docker Desktop**: Download from https://www.docker.com/products/docker-desktop/
2. **Start SQL Server**: Run `docker-compose up -d` in the project directory
3. **Connect to SQL Server**: See `Docker_Setup_Guide.md` for detailed instructions
4. **Connection Details**:
   - Server: `localhost` or `localhost,1433`
   - Authentication: SQL Server Authentication
   - Login: `sa`
   - Password: `971412811`

### Alternative: Traditional SQL Server Installation

1. **Connect to SQL Server**: See `SSMS_Connection_Guide.md` for step-by-step instructions
2. **Check Your Setup**: Run `Check_Setup.ps1` to verify what's installed
3. **Read Setup Guide**: See `Setup_Guide.md` for detailed installation instructions
4. **Install Missing Components**:
   - SQL Server with SSIS (Integration Services)
   - Visual Studio with SSDT (SQL Server Data Tools)
   - Microsoft Access Database Engine (for Excel connections)

## Quick Start Guide

### Step 0: Choose Your Setup Method

**Option A: Docker (Recommended - Easiest)**
- [ ] Docker Desktop installed
- [ ] SQL Server container running (`docker-compose up -d`)
- [ ] Connected to SQL Server in SSMS (see `Docker_Setup_Guide.md`)

**Option B: Traditional Installation**
- [ ] SQL Server is installed and running
- [ ] SSIS (Integration Services) is installed
- [ ] Visual Studio with SSDT is installed
- [ ] Microsoft Access Database Engine is installed

### Step 1: Database Setup

**If using Docker:**
1. Start container: `docker-compose up -d`
2. Connect in SSMS: `localhost` with `sa` / `YourStrong@Password123`
3. Execute SQL scripts (see `Docker_Setup_Guide.md` for details)

**If using traditional installation:**
1. Open SQL Server Management Studio (SSMS)
2. Connect to your SQL Server instance
3. Execute `products.sql` to create the Products table
4. Execute `CreateProcessedTransactionsTable.sql` to create the destination table

### Step 2: Create SSIS Package
1. Open Visual Studio
2. Create a new Integration Services Project
3. Follow the detailed instructions in `ETL_Implementation_Guide.md`
4. Configure all data sources and transformations as described

### Step 3: Execute and Validate
1. Execute the SSIS package (F5 in Visual Studio)
2. Verify successful execution
3. Run `ValidationQueries.sql` to validate the loaded data

## Files Description

### Data Source Files
- **transactions.csv**: Contains transaction records with TransactionID, ProductID, Quantity, and TransactionDate
- **customers.xlsx**: Contains customer information (CustomerID, Name, Email)
- **products.sql**: SQL script to create and populate the Products table

### SQL Scripts
- **products.sql**: Creates Products table and inserts sample data
- **CreateProcessedTransactionsTable.sql**: Creates the ProcessedTransactions destination table with proper indexes
- **ValidationQueries.sql**: Comprehensive validation queries to verify data quality after ETL execution

### Documentation
- **README.md**: Project overview and quick start guide
- **ETL_Implementation_Guide.md**: Detailed step-by-step instructions for creating the SSIS package in Visual Studio
- **ETL_Process_Report.md**: Comprehensive report documenting the ETL process, challenges, and solutions

## ETL Process Flow

```
[CSV Source]          [Excel Source]        [SQL Source]
   (Transactions)        (Customers)          (Products)
        |                     |                     |
        |                     |                     |
        +---------------------+---------------------+
                              |
                    [Merge Join - Combine Data]
                              |
                    [Derived Column - Handle Missing Data]
                              |
                    [Conditional Split - Filter Invalid]
                              |
                    [Sort - Remove Duplicates]
                              |
                    [Lookup - Validate ProductID]
                              |
                    [Derived Column - Calculate TotalCost]
                              |
                    [Conditional Split - Filter Zero Cost]
                              |
                    [Derived Column - Final Cleaning]
                              |
                    [OLE DB Destination]
                              |
                    [ProcessedTransactions Table]
```

## Key Transformations

1. **Extraction**: Flat File Source, Excel Source, OLE DB Source
2. **Joining**: Merge Join (Left Outer Join)
3. **Data Cleaning**: Derived Column (trim, uppercase, handle nulls)
4. **Validation**: Lookup (validate ProductID), Conditional Split (filter invalid)
5. **Deduplication**: Sort (remove duplicates)
6. **Calculation**: Derived Column (TotalCost = Quantity * Price)
7. **Loading**: OLE DB Destination (Fast Load)

## Prerequisites

- SQL Server with SSIS installed
- Visual Studio with SQL Server Data Tools (SSDT) or SSIS extension
- SQL Server Management Studio (SSMS)
- Microsoft Access Database Engine (for Excel connections)

## Validation

After executing the SSIS package, run the validation queries to verify:
- Total record counts
- Data quality (no NULLs in critical fields)
- Business rule compliance (TotalCost > 0, valid ProductIDs)
- Calculation accuracy (TotalCost = Quantity * Price)
- No duplicate records

## Troubleshooting

### Common Issues:
1. **Excel Connection Error**: Install Microsoft Access Database Engine
2. **Date Format Issues**: Configure date format in Flat File Connection Manager
3. **Foreign Key Violations**: Ensure all ProductIDs exist in Products table
4. **Memory Issues**: Adjust buffer size in Data Flow Task properties

For detailed troubleshooting, see `ETL_Implementation_Guide.md`.

## Next Steps

1. Review `ETL_Implementation_Guide.md` for detailed implementation steps
2. Create the SSIS package following the guide
3. Execute and test the package
4. Run validation queries
5. Review `ETL_Process_Report.md` for comprehensive documentation

## Support

For questions or issues:
1. Check the troubleshooting section in `ETL_Implementation_Guide.md`
2. Review the challenges and solutions in `ETL_Process_Report.md`
3. Verify all prerequisites are installed
4. Check SQL Server error logs and SSIS execution logs

---

**Good luck with your ETL implementation!**

