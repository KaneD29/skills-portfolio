# E-Commerce Growth & Profitability Analysis (Global Superstore)

## Project Overview
This project delivers an end-to-end SQL-based analysis of the **Global Superstore** dataset using **Microsoft SQL Server (SSMS)**. Designed with a focus on small business growth and profitability, the analysis uncovers revenue drivers, product profit margins, customer tier lifetime value, and actionable business insights.

The repository is modularized into structured, executable SQL scripts engineered for readability, maintainability, and query performance.

---

## Tech Stack & Database Environment
* **Database Engine**: Microsoft SQL Server
* **Interface**: SQL Server Management Studio (SSMS)
* **SQL Techniques Used**: CTEs (Common Table Expressions), Window Functions, Multi-tier Aggregations, Index Optimization, Conditional Business Logic (`CASE WHEN`), Date Arithmetic (`DATEDIFF`).

---

## Repository Structure

```text
├── README.md                           <- Executive summary, schema, and core findings
├── Assets/                             <- Organized query execution screenshots
│   ├── 03-Sales and Profitability/
│   ├── 04-Return Rate Analysis/
│   └── 05-Customer Segmentation/
├── 01_schema_and_import.sql            <- Database context, performance indexing, & row validation
├── 02_data_cleaning.sql                <- Duplicates check, whitespace trimming, & integrity rules
├── 03_sales_and_profitability.sql     <- Category margins, profit-trap products, & discount impact
├── 04_return_rate_analysis.sql        <- Return rates across categories, shipping modes, & regions
└── 05_customer_segmentation.sql       <- LTV tiering, RFM recency, & loyalty frequency metrics
```

# Key Business Insights

1. **Customer Segmentation & LTV Tiering** 
* **Pareto Distribution in Revenue:** Tier 1 (VIP) customers account for 39% of the customer base (621 of 1,591 total customers), yet drive 75.82% of total business revenue ($9,585,249.53) and generate $1,167,689.91 in gross profit.
* **Unprofitable Customer Segments:** Tier 4 (Low-Value) customers generate nearly $120,000 in top-line sales but result in a cumulative net loss of -$7,882.38. This indicates that acquisition costs or heavy discounting on low-tier buyers exceed their lifetime value.  

![Customer Tier Summary Metrics](Assets/05-Customer%20Segmentation/Customer-Tier-Summary-Metrics.png)
![Value-Based Customer Tiering](Assets/05-Customer%20Segmentation/Value-Based-Customer-Tiering.png)

---

2. **Repeat Purchase Loyalty Behavior**
* **Exponential LTV Growth:** Customer spending increases sharply once buyers cross the repeat-purchase threshold. Loyal buyers with 10 or more orders contribute over $11.25M in revenue with an average spend of $12,865.55 per customer.   
* **Retention Tipping Point:** Mid-tier buyers (2 to 4 orders) represent a key conversion opportunity. Transitioning customers from 2-4 orders into the 5+ order tier yields significantly higher LTV gains compared to acquiring single-time buyers.   

![Repeat Purchase Loyalty Analysis](Assets/05-Customer%20Segmentation/Repeat-Purchase-Behaviour&Loyalty-Analysis.png)
![Days Since Last Order](Assets/05-Customer%20Segmentation/Days-Since-Last-Order.png)

---

3. **Sales & Discount Margin Degradation**
* **The Discount Trap:** Analysis reveals that discounts exceeding 20% severely erode gross profit margins across key product categories. While heavy discounts drive order volume, high-volume items sold under deep promotional discounts convert into net-loss profit traps.
* **Category Margin Variability:** Certain high-revenue sub-categories generate top-line growth but drag down overall business profitability due to thin default margins paired with promotional discounting.

![Impact of Discount Levels](Assets/03-Sales%20and%20Profitability/Impact-of-Discount-Levels-on-Profitability.png)

![Overall Revenue and Profit Overview](Assets/03-Sales%20and%20Profitability/Overall-Revenue-and-Profit-Overview.png)
![Top 10 Unprofitable Products](Assets/03-Sales%20and%20Profitability/Top-10-Unprofitable-Products.png)

---

4. **Shipping & Fulfillment Operational Metrics**
* **Order Processing Baselines:** Fulfillment lead times scale predictably across delivery options, ranging from 0 days for Same Day shipping to an average of 5.0 days for Standard Class.
* **Operational Consistency:** Evaluating shipping lead times against order categories confirms consistent processing windows across primary fulfillment tiers.

![Shipping Mode vs Processing Time](Assets/04-Return%20Rate%20Analysis/Shipping-Mode-&-Order-Processing-Time-vs.-Returns.png)
![Overall Return Rate](Assets/04-Return%20Rate%20Analysis/Overall-Return-Rate.png)

---

## Strategic Recommendations for Small Businesses

* **VIP Customer Retention:** Implement dedicated loyalty programs and priority support for Tier 1 spenders to prevent churn, as losing even 5% of this group significantly impairs total profitability.   
* **Promotion & Discount Policy Reform:** Cap promotional discounting at a maximum of 20% across high-volume categories to prevent margin compression and negative profit trades.
* **Targeted Retention Nudges:** Implement automated post-purchase marketing flows aimed at buyers with 2 to 4 orders to accelerate progression toward 5+ lifetime orders.  

## How to Run the Scripts
1. Clone or download this repository.
2. Open SSMS and connect to your SQL Server instance.
3. Ensure the target database exists ([Project-Superstore]) and contains the base table dbo.Global_Superstore2.
4. Run scripts sequentially from SQL/01_schema_and_import.sql through SQL/05_customer_segmentation.sql.