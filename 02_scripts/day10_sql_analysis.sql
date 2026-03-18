-- ==========================================================
-- HONEYRICH LOGISTICS ANALYTICS
-- Day 10 - SQL Data Integration & Business Metrics
-- ==========================================================

-- ----------------------------------------------------------
-- 1. CREATE DATABASE
-- ----------------------------------------------------------

CREATE DATABASE IF NOT EXISTS honeyrich_analytics;
USE honeyrich_analytics;

-- ----------------------------------------------------------
-- 2. CREATE TABLES
-- ----------------------------------------------------------

DROP TABLE IF EXISTS supply_data;
CREATE TABLE supply_data (
    batch_id VARCHAR(50),
    vendor_name VARCHAR(255),
    product_name VARCHAR(255),
    quantity FLOAT,
    unit VARCHAR(50),
    cost_per_kg FLOAT,
    defect_rate_pct FLOAT,
    procurement_date DATE
);

DROP TABLE IF EXISTS sales_data;
CREATE TABLE sales_data (
    batch_id VARCHAR(50),
    sale_date DATE,
    product_category VARCHAR(255),
    quantity_sold FLOAT,
    unit VARCHAR(50),
    export_price_per_unit FLOAT,
    total_revenue_inr FLOAT,
    destination_city VARCHAR(255)
);

-- ----------------------------------------------------------
-- 3. LOAD DATA (UPDATE FILE PATH)
-- ----------------------------------------------------------

-- NOTE: Update file path based on your system

LOAD DATA INFILE 'C:/path/honeyrich_supply_logs.csv'
INTO TABLE supply_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/path/Sales_Data_Export_Realistic.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ----------------------------------------------------------
-- 4. VALIDATION CHECK
-- ----------------------------------------------------------

SELECT COUNT(*) AS supply_records FROM supply_data;
SELECT COUNT(*) AS sales_records FROM sales_data;

-- Check joinable rows
SELECT COUNT(*) AS matched_records
FROM supply_data s
JOIN sales_data e
ON s.batch_id = e.batch_id;

-- ----------------------------------------------------------
-- 5. CORE JOIN (SUPPLY + SALES)
-- ----------------------------------------------------------

SELECT 
    s.vendor_name,
    s.batch_id,
    s.quantity,
    s.cost_per_kg,
    e.quantity_sold,
    e.total_revenue_inr
FROM supply_data s
JOIN sales_data e
ON s.batch_id = e.batch_id;

-- ----------------------------------------------------------
-- 6. PROFIT CALCULATION (IMPORTANT)
-- ----------------------------------------------------------

SELECT 
    s.vendor_name,
    s.batch_id,
    e.total_revenue_inr,
    (s.quantity * s.cost_per_kg) AS procurement_cost,
    (e.total_revenue_inr - (s.quantity * s.cost_per_kg)) AS profit
FROM supply_data s
JOIN sales_data e
ON s.batch_id = e.batch_id;

-- ----------------------------------------------------------
-- 7. VENDOR LEVEL BUSINESS METRICS
-- ----------------------------------------------------------

SELECT 
    s.vendor_name,
    SUM(s.quantity) AS total_quantity,
    AVG(s.cost_per_kg) AS avg_cost,
    AVG(s.defect_rate_pct) AS avg_defect,
    SUM(e.total_revenue_inr) AS total_revenue,
    SUM(e.total_revenue_inr - (s.quantity * s.cost_per_kg)) AS total_profit
FROM supply_data s
JOIN sales_data e
ON s.batch_id = e.batch_id
GROUP BY s.vendor_name;

-- ----------------------------------------------------------
-- 8. TOP PROFITABLE VENDORS
-- ----------------------------------------------------------

SELECT 
    s.vendor_name,
    SUM(e.total_revenue_inr - (s.quantity * s.cost_per_kg)) AS total_profit
FROM supply_data s
JOIN sales_data e
ON s.batch_id = e.batch_id
GROUP BY s.vendor_name
ORDER BY total_profit DESC
LIMIT 5;

-- ----------------------------------------------------------
-- 9. LOW PROFIT / LOSS VENDORS
-- ----------------------------------------------------------

SELECT 
    s.vendor_name,
    SUM(e.total_revenue_inr - (s.quantity * s.cost_per_kg)) AS total_profit
FROM supply_data s
JOIN sales_data e
ON s.batch_id = e.batch_id
GROUP BY s.vendor_name
HAVING total_profit < 0;

-- 10. EXPORT RESULT


Use this if MySQL export is enabled

SELECT * FROM (
    SELECT 
        s.vendor_name,
        SUM(s.quantity) AS total_quantity,
        AVG(s.cost_per_kg) AS avg_cost,
        AVG(s.defect_rate_pct) AS avg_defect,
        SUM(e.total_revenue_inr) AS total_revenue,
        SUM(e.total_revenue_inr - (s.quantity * s.cost_per_kg)) AS total_profit
    FROM supply_data s
    JOIN sales_data e
    ON s.batch_id = e.batch_id
    GROUP BY s.vendor_name
) AS result
INTO OUTFILE 'C:/path/vendor_business_metrics.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';