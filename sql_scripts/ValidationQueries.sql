-- Validation Queries for ETL Process
-- Execute these queries after running the SSIS package to verify data quality

USE [YourDatabaseName]; -- Replace with your database name
GO

-- ============================================
-- 1. RECORD COUNT VALIDATION
-- ============================================

-- Total records in ProcessedTransactions
SELECT 
    'Total Records' AS Metric,
    COUNT(*) AS Count
FROM ProcessedTransactions;

-- Records by Product
SELECT 
    ProductID,
    ProductName,
    COUNT(*) AS TransactionCount,
    SUM(Quantity) AS TotalQuantity,
    SUM(TotalCost) AS TotalRevenue
FROM ProcessedTransactions
GROUP BY ProductID, ProductName
ORDER BY ProductID;

-- Records by Customer
SELECT 
    CustomerID,
    CustomerName,
    COUNT(*) AS TransactionCount,
    SUM(TotalCost) AS TotalSpent
FROM ProcessedTransactions
GROUP BY CustomerID, CustomerName
ORDER BY CustomerID;

-- ============================================
-- 2. DATA QUALITY CHECKS
-- ============================================

-- Check for NULL values in critical fields
SELECT 
    'NULL Check' AS CheckType,
    COUNT(*) AS RecordCount
FROM ProcessedTransactions
WHERE TransactionID IS NULL 
   OR ProductID IS NULL 
   OR Quantity IS NULL 
   OR Price IS NULL 
   OR TotalCost IS NULL;

-- Check for invalid ProductIDs (should not exist if validation worked)
SELECT 
    'Invalid ProductID' AS CheckType,
    pt.ProductID,
    COUNT(*) AS RecordCount
FROM ProcessedTransactions pt
LEFT JOIN Products p ON pt.ProductID = p.ProductID
WHERE p.ProductID IS NULL
GROUP BY pt.ProductID;

-- Check for negative or zero values
SELECT 
    'Invalid Values' AS CheckType,
    COUNT(*) AS RecordCount
FROM ProcessedTransactions
WHERE Quantity <= 0 
   OR Price <= 0 
   OR TotalCost <= 0;

-- Check for duplicate TransactionID + ProductID combinations
SELECT 
    'Duplicates' AS CheckType,
    TransactionID,
    ProductID,
    COUNT(*) AS DuplicateCount
FROM ProcessedTransactions
GROUP BY TransactionID, ProductID
HAVING COUNT(*) > 1;

-- ============================================
-- 3. BUSINESS RULE VALIDATIONS
-- ============================================

-- Verify TotalCost calculation (Quantity * Price = TotalCost)
SELECT 
    'Calculation Error' AS CheckType,
    TransactionID,
    ProductID,
    Quantity,
    Price,
    TotalCost,
    (Quantity * Price) AS CalculatedTotalCost,
    ABS(TotalCost - (Quantity * Price)) AS Difference
FROM ProcessedTransactions
WHERE ABS(TotalCost - (Quantity * Price)) > 0.01; -- Allow for rounding differences

-- Check for "Unknown" values (indicating missing data was replaced)
SELECT 
    'Unknown Values' AS CheckType,
    COUNT(*) AS RecordCount
FROM ProcessedTransactions
WHERE ProductName = 'UNKNOWN' 
   OR CustomerName = 'UNKNOWN'
   OR CustomerEmail = 'UNKNOWN';

-- Check date range
SELECT 
    'Date Range' AS CheckType,
    MIN(TransactionDate) AS EarliestDate,
    MAX(TransactionDate) AS LatestDate,
    COUNT(*) AS RecordCount
FROM ProcessedTransactions;

-- ============================================
-- 4. DATA COMPLETENESS CHECKS
-- ============================================

-- Compare source vs destination record counts
-- Note: Adjust these queries based on your actual source data

-- Expected: All valid transactions should be loaded
SELECT 
    'Source Transactions' AS Source,
    COUNT(*) AS Count
FROM (
    -- This would be your source CSV data
    -- Replace with actual source query if available
    SELECT 1 AS TransactionID UNION ALL
    SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) AS SourceData;

-- Actual: Loaded transactions
SELECT 
    'Loaded Transactions' AS Destination,
    COUNT(DISTINCT TransactionID) AS Count
FROM ProcessedTransactions;

-- ============================================
-- 5. SUMMARY REPORT
-- ============================================

-- Overall Summary
SELECT 
    'SUMMARY REPORT' AS ReportSection,
    '' AS Detail;

SELECT 
    'Total Transactions' AS Metric,
    COUNT(DISTINCT TransactionID) AS Value
FROM ProcessedTransactions

UNION ALL

SELECT 
    'Total Products' AS Metric,
    COUNT(DISTINCT ProductID) AS Value
FROM ProcessedTransactions

UNION ALL

SELECT 
    'Total Customers' AS Metric,
    COUNT(DISTINCT CustomerID) AS Value
FROM ProcessedTransactions

UNION ALL

SELECT 
    'Total Revenue' AS Metric,
    CAST(SUM(TotalCost) AS DECIMAL(10,2)) AS Value
FROM ProcessedTransactions

UNION ALL

SELECT 
    'Average Transaction Value' AS Metric,
    CAST(AVG(TotalCost) AS DECIMAL(10,2)) AS Value
FROM ProcessedTransactions

UNION ALL

SELECT 
    'Total Quantity Sold' AS Metric,
    SUM(Quantity) AS Value
FROM ProcessedTransactions;

-- ============================================
-- 6. SAMPLE DATA REVIEW
-- ============================================

-- View sample records
SELECT TOP 10
    TransactionID,
    ProductID,
    ProductName,
    CustomerID,
    CustomerName,
    Quantity,
    Price,
    TotalCost,
    TransactionDate,
    ProcessedDate
FROM ProcessedTransactions
ORDER BY ProcessedDate DESC;

GO




