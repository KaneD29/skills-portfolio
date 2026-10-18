-- ===============================================================================
-- Script Name : 05_customer_segmentation.sql
-- Project     : E-Commerce Growth & Profitability Analysis (Global Superstore)
-- Engine      : Microsoft SQL Server / SSMS
-- Description : Segments customers into tiers based on spending, purchase frequency,
--               and recency to support targeted retention and marketing strategies.
-- ===============================================================================

USE [Project-Superstore];
GO

-- -------------------------------------------------------------------------------
-- 1. Value-Based Customer Tiering (VIP vs. Standard)
-- -------------------------------------------------------------------------------
SELECT 
    Customer_ID,
    Customer_Name,
    Segment AS Market_Segment,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Lifetime_Spend,
    ROUND(SUM(Profit), 2) AS Lifetime_Profit_Contribution,
    CASE 
        WHEN SUM(Sales) >= 10000 THEN 'Tier 1: VIP (Spend >= $10k)'
        WHEN SUM(Sales) BETWEEN 5000 AND 9999.99 THEN 'Tier 2: High Value ($5k - $10k)'
        WHEN SUM(Sales) BETWEEN 1000 AND 4999.99 THEN 'Tier 3: Regular ($1k - $5k)'
        ELSE 'Tier 4: Low Value (< $1k)'
    END AS Customer_Tier
FROM dbo.Global_Superstore2
GROUP BY Customer_ID, Customer_Name, Segment
ORDER BY Lifetime_Spend DESC;
GO


-- -------------------------------------------------------------------------------
-- 2. Customer Tier Summary Metrics
-- -------------------------------------------------------------------------------
WITH CustomerTiers AS (
    SELECT 
        Customer_ID,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit,
        CASE 
            WHEN SUM(Sales) >= 10000 THEN 'Tier 1: VIP'
            WHEN SUM(Sales) BETWEEN 5000 AND 9999.99 THEN 'Tier 2: High Value'
            WHEN SUM(Sales) BETWEEN 1000 AND 4999.99 THEN 'Tier 3: Regular'
            ELSE 'Tier 4: Low Value'
        END AS Tier
    FROM dbo.Global_Superstore2
    GROUP BY Customer_ID
)
SELECT 
    Tier,
    COUNT(Customer_ID) AS Total_Customers,
    ROUND(SUM(Total_Sales), 2) AS Tier_Revenue,
    ROUND(SUM(Total_Profit), 2) AS Tier_Profit,
    ROUND((SUM(Total_Sales) / (SELECT SUM(Sales) FROM dbo.Global_Superstore2)) * 100, 2) AS Pct_Of_Total_Revenue
FROM CustomerTiers
GROUP BY Tier
ORDER BY Tier_Revenue DESC;
GO


-- -------------------------------------------------------------------------------
-- 3. Repeat Purchase Behavior & Loyalty Analysis
-- -------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Order_Count = 1 THEN '1-Time Buyer'
        WHEN Order_Count BETWEEN 2 AND 4 THEN '2-4 Orders (Occasional)'
        WHEN Order_Count BETWEEN 5 AND 9 THEN '5-9 Orders (Frequent)'
        ELSE '10+ Orders (Loyal)'
    END AS Purchase_Frequency_Group,
    COUNT(Customer_ID) AS Total_Customers,
    ROUND(SUM(Total_Customer_Sales), 2) AS Group_Revenue,
    ROUND(AVG(Total_Customer_Sales), 2) AS Avg_Spend_Per_Customer
FROM (
    SELECT 
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Order_Count,
        SUM(Sales) AS Total_Customer_Sales
    FROM dbo.Global_Superstore2
    GROUP BY Customer_ID
) AS CustomerOrders
GROUP BY 
    CASE 
        WHEN Order_Count = 1 THEN '1-Time Buyer'
        WHEN Order_Count BETWEEN 2 AND 4 THEN '2-4 Orders (Occasional)'
        WHEN Order_Count BETWEEN 5 AND 9 THEN '5-9 Orders (Frequent)'
        ELSE '10+ Orders (Loyal)'
    END
ORDER BY Group_Revenue DESC;
GO


-- -------------------------------------------------------------------------------
-- 4. Simple RFM Recency Proxy (Days Since Last Order)
-- -------------------------------------------------------------------------------
WITH MaxDate AS (
    SELECT MAX(Order_Date) AS Dataset_Max_Date FROM dbo.Global_Superstore2
)
SELECT 
    o.Customer_ID,
    o.Customer_Name,
    MAX(o.Order_Date) AS Last_Order_Date,
    DATEDIFF(day, MAX(o.Order_Date), m.Dataset_Max_Date) AS Days_Since_Last_Order,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    ROUND(SUM(o.Sales), 2) AS Lifetime_Spend,
    CASE 
        WHEN DATEDIFF(day, MAX(o.Order_Date), m.Dataset_Max_Date) <= 90 THEN 'Active (Last 3 Mo)'
        WHEN DATEDIFF(day, MAX(o.Order_Date), m.Dataset_Max_Date) BETWEEN 91 AND 180 THEN 'At-Risk (3-6 Mo)'
        WHEN DATEDIFF(day, MAX(o.Order_Date), m.Dataset_Max_Date) BETWEEN 181 AND 365 THEN 'Lapsing (6-12 Mo)'
        ELSE 'Inactive (> 1 Year)'
    END AS Recency_Status
FROM dbo.Global_Superstore2 o
CROSS JOIN MaxDate m
GROUP BY o.Customer_ID, o.Customer_Name, m.Dataset_Max_Date
ORDER BY Days_Since_Last_Order ASC;
GO


-- -------------------------------------------------------------------------------
-- 5. Top Customer Segment Preference Breakdown
-- -------------------------------------------------------------------------------
SELECT 
    Segment AS Customer_Segment,
    Category,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM dbo.Global_Superstore2
GROUP BY Segment, Category
ORDER BY Customer_Segment, Total_Sales DESC;
GO