-- ===============================================================================
-- Script Name : 01_schema_and_import.sql
-- Project     : E-Commerce Growth & Profitability Analysis (Global Superstore)
-- Engine      : Microsoft SQL Server / SSMS
-- Description : Database schema validation and performance indexing.
-- ===============================================================================

USE [Project-Superstore];
GO

-- 1. Create Indexes to Improve Query Performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GlobalSuperstore_Category_SubCat')
BEGIN
    CREATE NONCLUSTERED INDEX IX_GlobalSuperstore_Category_SubCat 
    ON dbo.Global_Superstore2 (Category, Sub_Category);
END;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GlobalSuperstore_Customer')
BEGIN
    CREATE NONCLUSTERED INDEX IX_GlobalSuperstore_Customer 
    ON dbo.Global_Superstore2 (Customer_ID, Segment);
END;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GlobalSuperstore_Dates')
BEGIN
    CREATE NONCLUSTERED INDEX IX_GlobalSuperstore_Dates 
    ON dbo.Global_Superstore2 (Order_Date, Ship_Date);
END;
GO

-- 2. Validate Imported Row Counts
SELECT 
    'dbo.Global_Superstore2' AS Table_Name, 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Order_ID) AS Total_Unique_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Unique_Customers
FROM dbo.Global_Superstore2;
GO