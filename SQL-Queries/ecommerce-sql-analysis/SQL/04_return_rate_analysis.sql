-- ===============================================================================
-- Script Name : 04_return_rate_analysis.sql
-- Project     : E-Commerce Growth & Profitability Analysis (Global Superstore)
-- Engine      : Microsoft SQL Server / SSMS
-- Description : Analyzes order returns, lost revenue, and return patterns.
--               Includes dynamic safeguards to handle missing returns tables gracefully.
-- ===============================================================================

USE [Project-Superstore];
GO

-- -------------------------------------------------------------------------------
-- 0. Check / Create Staging Returns Table if Missing
-- -------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Returns', 'U') IS NULL
BEGIN
    PRINT 'Notice: dbo.Returns table not detected. Creating an empty staging schema to prevent query errors.';
    
    CREATE TABLE dbo.Returns (
        Returned NVARCHAR(10) NULL,
        Order_ID NVARCHAR(255) NULL,
        Region NVARCHAR(50) NULL
    );
END;
GO


-- -------------------------------------------------------------------------------
-- 1. Overall Return Summary & Financial Impact
-- -------------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT r.Order_ID) AS Total_Returned_Orders,
    ROUND((CAST(COUNT(DISTINCT r.Order_ID) AS FLOAT) / NULLIF(COUNT(DISTINCT o.Order_ID), 0)) * 100, 2) AS Overall_Return_Rate_Pct,
    ROUND(SUM(CASE WHEN r.Order_ID IS NOT NULL THEN o.Sales ELSE 0 END), 2) AS Lost_Revenue_From_Returns,
    ROUND(SUM(CASE WHEN r.Order_ID IS NOT NULL THEN o.Profit ELSE 0 END), 2) AS Lost_Profit_From_Returns
FROM dbo.Global_Superstore2 o
LEFT JOIN dbo.Returns r 
    ON o.Order_ID = r.Order_ID;
GO


-- -------------------------------------------------------------------------------
-- 2. Return Rate by Product Category & Sub-Category
-- -------------------------------------------------------------------------------
SELECT 
    o.Category,
    o.Sub_Category,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT r.Order_ID) AS Returned_Orders,
    ROUND((CAST(COUNT(DISTINCT r.Order_ID) AS FLOAT) / NULLIF(COUNT(DISTINCT o.Order_ID), 0)) * 100, 2) AS Return_Rate_Pct,
    ROUND(SUM(CASE WHEN r.Order_ID IS NOT NULL THEN o.Sales ELSE 0 END), 2) AS Returned_Sales_Value
FROM dbo.Global_Superstore2 o
LEFT JOIN dbo.Returns r 
    ON o.Order_ID = r.Order_ID
GROUP BY o.Category, o.Sub_Category
ORDER BY Return_Rate_Pct DESC, Total_Orders DESC;
GO


-- -------------------------------------------------------------------------------
-- 3. Return Rate by Region
-- -------------------------------------------------------------------------------
SELECT 
    o.Market,
    o.Region,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT r.Order_ID) AS Returned_Orders,
    ROUND((CAST(COUNT(DISTINCT r.Order_ID) AS FLOAT) / NULLIF(COUNT(DISTINCT o.Order_ID), 0)) * 100, 2) AS Return_Rate_Pct,
    ROUND(SUM(CASE WHEN r.Order_ID IS NOT NULL THEN o.Sales ELSE 0 END), 2) AS Returned_Sales_Value
FROM dbo.Global_Superstore2 o
LEFT JOIN dbo.Returns r 
    ON o.Order_ID = r.Order_ID
GROUP BY o.Market, o.Region
ORDER BY Return_Rate_Pct DESC;
GO


-- -------------------------------------------------------------------------------
-- 4. Shipping Mode & Order Processing Time vs. Returns
-- -------------------------------------------------------------------------------
SELECT 
    o.Ship_Mode,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT r.Order_ID) AS Returned_Orders,
    ROUND((CAST(COUNT(DISTINCT r.Order_ID) AS FLOAT) / NULLIF(COUNT(DISTINCT o.Order_ID), 0)) * 100, 2) AS Return_Rate_Pct,
    ROUND(AVG(CAST(DATEDIFF(day, o.Order_Date, o.Ship_Date) AS FLOAT)), 1) AS Avg_Shipping_Days
FROM dbo.Global_Superstore2 o
LEFT JOIN dbo.Returns r 
    ON o.Order_ID = r.Order_ID
GROUP BY o.Ship_Mode
ORDER BY Return_Rate_Pct DESC;
GO


-- -------------------------------------------------------------------------------
-- 5. Top 10 Frequently Returned Products
-- -------------------------------------------------------------------------------
SELECT TOP 10
    o.Product_ID,
    o.Product_Name,
    o.Category,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT r.Order_ID) AS Times_Returned,
    ROUND((CAST(COUNT(DISTINCT r.Order_ID) AS FLOAT) / NULLIF(COUNT(DISTINCT o.Order_ID), 0)) * 100, 2) AS Product_Return_Rate_Pct
FROM dbo.Global_Superstore2 o
LEFT JOIN dbo.Returns r 
    ON o.Order_ID = r.Order_ID
GROUP BY o.Product_ID, o.Product_Name, o.Category
HAVING COUNT(DISTINCT o.Order_ID) >= 5
ORDER BY Product_Return_Rate_Pct DESC, Times_Returned DESC;
GO