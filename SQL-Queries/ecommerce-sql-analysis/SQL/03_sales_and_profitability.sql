-- ===============================================================================
-- Script Name : 03_sales_and_profitability.sql
-- Project     : E-Commerce Growth & Profitability Analysis (Global Superstore)
-- Engine      : Microsoft SQL Server / SSMS
-- Description : Evaluates sales performance, profit margins, product profitability,
--               and discount impacts to highlight business growth opportunities.
-- ===============================================================================

USE [Project-Superstore];
GO

-- -------------------------------------------------------------------------------
-- 1. Overall Revenue & Profit Overview
-- -------------------------------------------------------------------------------
-- Summary metrics across the entire business portfolio.
SELECT 
    ROUND(SUM(Sales), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Quantity), 0) AS Total_Units_Sold,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS Overall_Profit_Margin_Pct
FROM dbo.Global_Superstore2;
GO


-- -------------------------------------------------------------------------------
-- 2. Category & Sub-Category Profitability Analysis
-- -------------------------------------------------------------------------------
-- Identifies high-revenue categories and sub-categories that suffer from low margins.
SELECT 
    Category,
    Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS Profit_Margin_Pct
FROM dbo.Global_Superstore2
GROUP BY Category, Sub_Category
ORDER BY Total_Sales DESC;
GO


-- -------------------------------------------------------------------------------
-- 3. Top 10 Unprofitable "Profit Trap" Products
-- -------------------------------------------------------------------------------
-- Finds products generating volume but draining overall business profitability.
SELECT TOP 10
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Loss
FROM dbo.Global_Superstore2
GROUP BY Product_ID, Product_Name, Category, Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Loss ASC;
GO


-- -------------------------------------------------------------------------------
-- 4. Impact of Discount Levels on Profitability
-- -------------------------------------------------------------------------------
-- Evaluates how aggressive discounting affects profit margins.
SELECT 
    CASE 
        WHEN Discount = 0 THEN '0% (No Discount)'
        WHEN Discount > 0 AND Discount <= 0.20 THEN '1% - 20% Discount'
        WHEN Discount > 0.20 AND Discount <= 0.50 THEN '21% - 50% Discount'
        ELSE 'Above 50% Discount'
    END AS Discount_Tier,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS Profit_Margin_Pct
FROM dbo.Global_Superstore2
GROUP BY 
    CASE 
        WHEN Discount = 0 THEN '0% (No Discount)'
        WHEN Discount > 0 AND Discount <= 0.20 THEN '1% - 20% Discount'
        WHEN Discount > 0.20 AND Discount <= 0.50 THEN '21% - 50% Discount'
        ELSE 'Above 50% Discount'
    END
ORDER BY Profit_Margin_Pct DESC;
GO


-- -------------------------------------------------------------------------------
-- 5. Regional Sales & Margin Ranking
-- -------------------------------------------------------------------------------
-- Compares sales volume and profit margin percentages across global regions.
SELECT 
    Market,
    Region,
    ROUND(SUM(Sales), 2) AS Regional_Sales,
    ROUND(SUM(Profit), 2) AS Regional_Profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS Regional_Margin_Pct
FROM dbo.Global_Superstore2
GROUP BY Market, Region
ORDER BY Regional_Sales DESC;
GO