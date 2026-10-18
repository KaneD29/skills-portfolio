-- ===============================================================================
-- Script Name : 02_data_cleaning.sql
-- Project     : E-Commerce Growth & Profitability Analysis (Global Superstore)
-- Engine      : Microsoft SQL Server / SSMS
-- Description : Cleans and prepares raw imported data for analysis.
-- ===============================================================================

USE [Project-Superstore];
GO

-- -------------------------------------------------------------------------------
-- 1. Check for Duplicate Rows
-- -------------------------------------------------------------------------------
-- Verify if Row_ID is unique across the dataset
SELECT 
    Row_ID, 
    COUNT(*) AS Duplicate_Count
FROM dbo.Global_Superstore2
GROUP BY Row_ID
HAVING COUNT(*) > 1;
GO

-- Check for line item duplicates (same order, customer, product, date)
SELECT 
    Order_ID, 
    Customer_ID, 
    Product_ID, 
    Order_Date, 
    COUNT(*) AS Line_Duplicates
FROM dbo.Global_Superstore2
GROUP BY Order_ID, Customer_ID, Product_ID, Order_Date
HAVING COUNT(*) > 1;
GO


-- -------------------------------------------------------------------------------
-- 2. Clean Nulls & Missing Values
-- -------------------------------------------------------------------------------
-- Check for NULLs in critical reporting columns
SELECT 
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Null_Orders,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Null_Customers,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Null_Sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Null_Profit
FROM dbo.Global_Superstore2;
GO


-- -------------------------------------------------------------------------------
-- 3. String Trimming & Formatting
-- -------------------------------------------------------------------------------
-- Trim whitespace from core text columns to prevent join/grouping discrepancies
UPDATE dbo.Global_Superstore2
SET 
    Customer_Name = LTRIM(RTRIM(Customer_Name)),
    City          = LTRIM(RTRIM(City)),
    State         = LTRIM(RTRIM(State)),
    Country       = LTRIM(RTRIM(Country)),
    Category      = LTRIM(RTRIM(Category)),
    Sub_Category  = LTRIM(RTRIM(Sub_Category)),
    Product_Name  = LTRIM(RTRIM(Product_Name));
GO


-- -------------------------------------------------------------------------------
-- 4. Anomaly Checks & Integrity Rules
-- -------------------------------------------------------------------------------
-- Identify any negative or zero sales/quantities
SELECT 
    Row_ID, Order_ID, Sales, Quantity, Profit
FROM dbo.Global_Superstore2
WHERE Sales <= 0 OR Quantity <= 0;

-- Check for logic errors where Ship Date precedes Order Date
SELECT 
    Row_ID, Order_ID, Order_Date, Ship_Date
FROM dbo.Global_Superstore2
WHERE Ship_Date < Order_Date;
GO


-- -------------------------------------------------------------------------------
-- 5. Data Validation Summary
-- -------------------------------------------------------------------------------
SELECT 
    'Orders Cleaned' AS Check_Status,
    COUNT(*) AS Total_Records,
    MIN(Order_Date) AS Earliest_Order,
    MAX(Order_Date) AS Latest_Order
FROM dbo.Global_Superstore2;
GO