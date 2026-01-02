# SSIS ETL Process Implementation Guide

## Overview
This guide provides step-by-step instructions for implementing an ETL process using SQL Server Integration Services (SSIS) to extract, transform, and load data from multiple sources into a consolidated `ProcessedTransactions` table.

## Prerequisites
- SQL Server with SSIS installed
- Visual Studio with SQL Server Data Tools (SSDT) or SSIS extension
- SQL Server Management Studio (SSMS)
- Access to the source files: `transactions.csv`, `customers.xlsx`

## Step 1: Database Setup

### 1.1 Create Products Table
Execute the `products.sql` script in SSMS to create and populate the Products table.

### 1.2 Create ProcessedTransactions Table
Execute the `CreateProcessedTransactionsTable.sql` script in SSMS to create the destination table.

## Step 2: Create SSIS Project

1. Open Visual Studio
2. Create a new project: **Integration Services Project**
3. Name it: `ETL_Assignment4`
4. Save the project

## Step 3: Create Data Flow Task

### 3.1 Add Data Flow Task
1. In the **Control Flow** tab, drag a **Data Flow Task** from the SSIS Toolbox
2. Rename it to: `ETL_Process_Transactions`
3. Double-click to open the **Data Flow** tab

## Step 4: Extraction - Add Data Sources

### 4.1 Extract from CSV (Transactions)
1. Drag **Flat File Source** from the SSIS Toolbox
2. Rename to: `FF_Source_Transactions`
3. Right-click → **Edit**
4. Click **New** to create a new Flat File Connection Manager
5. Configure:
   - **Connection Manager Name**: `FF_Transactions`
   - **File Path**: Browse to `transactions.csv` (in your `data` folder)
   - **Format**: Delimited
   - **Text Qualifier**: None
   - **Header Row Delimiter**: {CR}{LF}
   - **Column Names in First Row**: Checked
6. Go to **Columns** tab:
   - Verify columns: TransactionID, ProductID, Quantity, TransactionDate
   - Set data types:
     - TransactionID: four-byte signed integer [DT_I4]
     - ProductID: four-byte signed integer [DT_I4]
     - Quantity: four-byte signed integer [DT_I4]
     - TransactionDate: date [DT_DATE]
7. Click **OK**
8. **Note**: You'll see two output arrows:
   - **BLUE arrow** (left side) = Default output (use this for data flow)
   - **RED/ORANGE arrow** (right side) = Error output (for error handling, ignore for now)

### 4.2 Extract from Excel (Customers)
1. Drag **Excel Source** from the SSIS Toolbox
2. Rename to: `Excel_Source_Customers`
3. Right-click → **Edit**
4. Click **New** to create a new Excel Connection Manager
5. Configure:
   - **Connection Manager Name**: `Excel_Customers`
   - **Excel File Path**: Browse to `customers.xlsx` (in your `data` folder)
   - **Excel Version**: Microsoft Excel 12.0 (or appropriate version)
6. Go to **Data Access Mode**: Table or View
7. Select the worksheet containing customer data
8. Click **OK**
9. **Note**: Like the Flat File Source, you'll see:
   - **BLUE arrow** (left) = Default output (use this)
   - **RED/ORANGE arrow** (right) = Error output (ignore for now)

### 4.3 Extract from SQL (Products)
1. Drag **OLE DB Source** from the SSIS Toolbox
2. Rename to: `OLE_Source_Products`
3. Right-click → **Edit**
4. Click **New** to create a new OLE DB Connection Manager
5. Configure:
   - **Server Name**: `localhost` (or your Docker SQL Server)
   - **Authentication**: SQL Server Authentication
   - **Login**: `sa`
   - **Password**: `YourStrong@Pass123`
   - **Database**: `ETL` (or your database name)
6. **Data Access Mode**: Table or View
7. **Table or View**: Select `Products` table
8. Click **OK**
9. **Note**: OLE DB Source also has:
   - **BLUE arrow** (left) = Default output (use this)
   - **RED/ORANGE arrow** (right) = Error output (ignore for now)

## Step 5: Transformation - Data Cleaning and Validation

### 5.1 Merge Data Sources

**⚠️ IMPORTANT: Merge Join requires sorted inputs!** You must sort both data sources on the join key before connecting to Merge Join.

#### Step 1: Add Sort Transformations

1. **Add Sort transformation for Transactions:**
   - Drag **Sort** from SSIS Toolbox
   - Rename to: `Sort_Transactions`
   - Connect `FF_Source_Transactions` (BLUE arrow) → `Sort_Transactions`
   - Right-click `Sort_Transactions` → **Edit**
   - In **Sort Keys** section:
     * Check `ProductID` → Set to **Ascending**
     * Check **"Pass Through"** for all other columns (TransactionID, Quantity, TransactionDate)
   - Click **OK**

2. **Add Sort transformation for Products:**
   - Drag another **Sort** from SSIS Toolbox
   - Rename to: `Sort_Products`
   - Connect `OLE_Source_Products` (BLUE arrow) → `Sort_Products`
   - Right-click `Sort_Products` → **Edit**
   - In **Sort Keys** section:
     * Check `ProductID` → Set to **Ascending**
     * Check **"Pass Through"** for all other columns (ProductName, Price, Stock)
   - Click **OK**

#### Step 2: Add and Connect Merge Join

1. Add **Merge Join** transformation from the SSIS Toolbox
2. **Connect the SORTED data sources to Merge Join:**
   - **Important**: Connect from the **Sort transformations**, NOT directly from sources!
   - Connect `Sort_Transactions` (BLUE arrow) → `Merge Join`
   - Connect `Sort_Products` (BLUE arrow) → `Merge Join`
3. **Configure Merge Join:**
   - Right-click **Merge Join** → **Edit**
   - **Join Type**: Left Outer Join
   - **Understanding Left vs Right Input:**
     * **Left Input** = The FIRST data source you want to keep all rows from (usually your main/primary table)
     * **Right Input** = The SECOND data source you're joining to (usually lookup/reference table)
   - **For this assignment:**
     * **Left Input**: Select `Sort_Transactions Output` (Sorted Transactions - we want all transactions)
     * **Right Input**: Select `Sort_Products Output` (Sorted Products - we're looking up product details)
   - **Important**: Both inputs should show `IsSorted = True` in the dropdown (this is set automatically when you connect from Sort transformations)
   - **Join Key**: 
     * In the **Left Input** section, check `ProductID`
     * In the **Right Input** section, check `ProductID`
     * This creates the join: `ProductID = ProductID`
   - **Output Columns**: 
     * Check all columns you want in the output from both inputs
     * Typically: TransactionID, ProductID, Quantity, TransactionDate (from Transactions)
     * And: ProductName, Price (from Products)
   - Click **OK**

### 5.2 Add Customer Data

**⚠️ IMPORTANT: Both inputs must be sorted on CustomerID!**

**Note**: Your `transactions.csv` doesn't have a `CustomerID` column. You need to add it first using a Derived Column.

#### Step 1: Add CustomerID to Transactions Data

1. **Add Derived Column transformation after first Merge Join:**
   - Drag **Derived Column** from SSIS Toolbox
   - Rename to: `DC_AddCustomerID`
   - Connect the **first Merge Join** (BLUE arrow) → `DC_AddCustomerID`
   - Right-click `DC_AddCustomerID` → **Edit**
   - In **Derived Column Name**: Enter `CustomerID`
   - In **Derived Column**: Select `<add as new column>`
   - In **Expression**: 
     * **Option 1** (Assign based on TransactionID): `(TransactionID % 5) + 1` 
       - This assigns CustomerID 1-5 based on TransactionID
     * **Option 2** (Assign default value): `1`
       - This assigns all transactions to CustomerID = 1
     * **Option 3** (Manual mapping): Create a more complex expression based on your business logic
   - **Data Type**: four-byte signed integer [DT_I4]
   - Click **OK**

#### Step 2: Sort the Merged Data (with CustomerID)

1. **Add Sort transformation:**
   - Drag **Sort** from SSIS Toolbox
   - Rename to: `Sort_MergedData`
   - Connect `DC_AddCustomerID` (BLUE arrow) → `Sort_MergedData`
   - Right-click `Sort_MergedData` → **Edit**
   - In **Sort Keys** section:
     * Check `CustomerID` → Set to **Ascending**
     * Check **"Pass Through"** for all other columns (TransactionID, ProductID, ProductName, Quantity, Price, TransactionDate)
   - Click **OK**

#### Step 3: Sort Customer Data

1. **Add Sort transformation for Customers:**
   - Drag **Sort** from SSIS Toolbox
   - Rename to: `Sort_Customers`
   - Connect `Excel_Source_Customers` (BLUE arrow) → `Sort_Customers`
   - Right-click `Sort_Customers` → **Edit**
   - In **Sort Keys** section:
     * Check `CustomerID` → Set to **Ascending**
     * Check **"Pass Through"** for all other columns (Name, Email, etc.)
   - Click **OK**

#### Step 4: Add Second Merge Join

1. **Add another Merge Join transformation**
2. **Connect the SORTED data sources:**
   - **From Sort_MergedData**: Drag from its **BLUE output arrow** to the new Merge Join
   - **From Sort_Customers**: Drag from its **BLUE output arrow** to the new Merge Join
3. **Configure the second Merge Join:**
   - Right-click → **Edit**
   - **Join Type**: Left Outer Join
   - **Left Input**: Select `Sort_MergedData Output` (Sorted Transactions + Products data)
   - **Right Input**: Select `Sort_Customers Output` (Sorted Customer data)
   - **Join Key**: 
     * In the **Left Input** section, check `CustomerID`
     * In the **Right Input** section, check `CustomerID`
     * This creates the join: `CustomerID = CustomerID`
   - **Output Columns**: Select all columns you need from both inputs:
     * From Left: TransactionID, ProductID, ProductName, Quantity, Price, TransactionDate, CustomerID
     * From Right: CustomerID (from customers), CustomerName (or Name), CustomerEmail (or Email)
     * **Note**: You'll see CustomerID from both sides - you can uncheck one (they should match after the join)
   - Click **OK**

**Important**: Make sure the CustomerID data types match:
- In `DC_AddCustomerID`: Use `[DT_I4]` (four-byte signed integer)
- In Excel Source: CustomerID should also be `[DT_I4]`
- If types don't match, add a Data Conversion transformation to convert them

### 5.3 Handle Missing Data - Derived Column
1. Add **Derived Column** transformation
2. Rename to: `DC_HandleMissingData`
3. Connect Merge Join output to this transformation
4. Add expressions:
   ```
   ProductID == NULL ? 0 : ProductID
   ProductName == NULL || TRIM(ProductName) == "" ? "Unknown" : TRIM(UPPER(ProductName))
   CustomerName == NULL || TRIM(CustomerName) == "" ? "Unknown" : TRIM(UPPER(CustomerName))
   CustomerEmail == NULL || TRIM(CustomerEmail) == "" ? "Unknown" : TRIM(CustomerEmail)
   Quantity == NULL ? 0 : Quantity
   Price == NULL ? 0.00 : Price
   ```

### 5.4 Remove Rows with Missing Critical Values
1. Add **Conditional Split** transformation
2. Rename to: `CS_FilterMissingCritical`
3. Add output condition:
   - **Output Name**: `ValidRows`
   - **Condition**: `ProductID != NULL && ProductID > 0 && Quantity != NULL && Price != NULL`
   - **Default Output Name**: `InvalidRows`
4. Connect `InvalidRows` to a **Row Count** transformation (for logging) or **OLE DB Destination** (to a staging table for review)

### 5.5 Remove Duplicates
1. Add **Sort** transformation
2. Rename to: `Sort_RemoveDuplicates`
3. Configure:
   - **Sort Type**: Ascending
   - **Sort Keys**: TransactionID, ProductID
   - **Remove Rows with Duplicate Sort Values**: Checked
   - **Pass Through**: All other columns

### 5.6 Data Validation - Lookup Products
1. Add **Lookup** transformation
2. Rename to: `Lookup_ValidateProduct`
3. Configure:
   - **Connection**: OLE DB Connection to Products table
   - **Use Table or View**: Products
   - **Join Columns**: ProductID = ProductID
   - **Available Lookup Columns**: ProductName, Price
   - **Specify How to Handle Rows with No Matching Entries**: Redirect rows to no match output
4. Connect "No Match" output to a **Row Count** for logging invalid ProductIDs

### 5.7 Calculate Total Cost
1. Add **Derived Column** transformation
2. Rename to: `DC_CalculateTotalCost`
3. Add expression:
   ```
   TotalCost = Quantity * Price
   ```

### 5.8 Filter Invalid Transactions
1. Add **Conditional Split** transformation
2. Rename to: `CS_FilterInvalidCost`
3. Add output condition:
   - **Output Name**: `ValidCost`
   - **Condition**: `TotalCost > 0 && Quantity > 0 && Price > 0`
   - **Default Output Name**: `InvalidCost`
4. Connect `InvalidCost` to a **Row Count** for logging

### 5.9 Final Data Cleaning
1. Add **Derived Column** transformation
2. Rename to: `DC_FinalCleaning`
3. Add expressions:
   ```
   ProductName = TRIM(UPPER(ProductName))
   CustomerName = TRIM(UPPER(CustomerName))
   CustomerEmail = LOWER(TRIM(CustomerEmail))
   ```

## Step 6: Loading - Destination

### 6.1 Add OLE DB Destination
1. Add **OLE DB Destination** transformation
2. Rename to: `OLE_Dest_ProcessedTransactions`
3. Connect the final transformation output to this destination
4. Right-click → **Edit**
5. Configure:
   - **OLE DB Connection Manager**: Select your database connection
   - **Data Access Mode**: Table or View - Fast Load
   - **Table or View**: `ProcessedTransactions`
6. Go to **Mappings** tab:
   - Map source columns to destination columns:
     - TransactionID → TransactionID
     - ProductID → ProductID
     - ProductName → ProductName
     - CustomerID → CustomerID
     - CustomerName → CustomerName
     - CustomerEmail → CustomerEmail
     - Quantity → Quantity
     - Price → Price
     - TotalCost → TotalCost
     - TransactionDate → TransactionDate
7. Click **OK**

## Step 7: Error Handling

### 7.1 Add Error Outputs
1. For each transformation, configure error outputs:
   - Right-click transformation → **Show Advanced Editor**
   - Go to **Input and Output Properties**
   - Configure error handling for each column

### 7.2 Add Error Logging
1. Add **Row Count** transformations for error paths
2. Add variables to store error counts
3. Add **Script Task** or **Execute SQL Task** to log errors to a table

## Step 8: Package Execution

### 8.1 Test the Package
1. Set breakpoints if needed
2. Press **F5** or click **Start Debugging**
3. Monitor execution in the **Progress** tab
4. Check for errors and warnings

### 8.2 Execute in Production
1. Build the solution (Build → Build Solution)
2. Deploy to SSIS Catalog (optional)
3. Execute using SQL Server Agent or SSIS Catalog

## Step 9: Validation

### 9.1 Verify Results
Execute the validation queries in `ValidationQueries.sql` to verify:
- Total record count
- Data quality checks
- Business rule validations

## Troubleshooting

### Common Issues:
1. **Excel Connection Error**: Ensure Microsoft Access Database Engine is installed
2. **Date Format Issues**: Configure date format in Flat File Connection Manager
3. **Memory Issues**: Adjust buffer size in Data Flow Task properties
4. **Foreign Key Violations**: Ensure all ProductIDs exist in Products table before running

## Performance Optimization Tips

1. Use **Fast Load** option in OLE DB Destination
2. Set appropriate **DefaultBufferMaxRows** and **DefaultBufferSize**
3. Use **Sort** transformation only when necessary
4. Consider using **Union All** instead of multiple Merge Joins if possible
5. Add indexes on join columns in source tables




