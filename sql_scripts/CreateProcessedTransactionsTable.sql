-- Create the ProcessedTransactions destination table
-- This table will store the cleaned and transformed transaction data

IF OBJECT_ID('ProcessedTransactions', 'U') IS NOT NULL
    DROP TABLE ProcessedTransactions;
GO

CREATE TABLE ProcessedTransactions (
    TransactionID INT NOT NULL,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(50),
    CustomerID INT,
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    TotalCost DECIMAL(10, 2) NOT NULL,
    TransactionDate DATE,
    ProcessedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_ProcessedTransactions PRIMARY KEY (TransactionID, ProductID),
    CONSTRAINT FK_ProcessedTransactions_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- Create index for better query performance
CREATE INDEX IX_ProcessedTransactions_ProductID ON ProcessedTransactions(ProductID);
CREATE INDEX IX_ProcessedTransactions_CustomerID ON ProcessedTransactions(CustomerID);
CREATE INDEX IX_ProcessedTransactions_TransactionDate ON ProcessedTransactions(TransactionDate);
GO

PRINT 'ProcessedTransactions table created successfully!';
GO




