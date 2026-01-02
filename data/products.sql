
-- Create the Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(50),
    Price DECIMAL(10, 2),
    Stock INT
);

-- Insert data into the Products table
INSERT INTO Products (ProductID, ProductName, Price, Stock) VALUES
(1, 'Laptop', 899.99, 50),
(2, 'Smartphone', 499.99, 100),
(3, 'Tablet', 299.99, 75),
(4, 'Headphones', 49.99, 200),
(5, 'Smartwatch', 199.99, 120);
