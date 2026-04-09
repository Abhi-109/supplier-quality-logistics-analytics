
CREATE DATABASE IF NOT EXISTS honeyrich_analytics;
USE honeyrich_analytics;

DROP TABLE IF EXISTS supply_data;

CREATE TABLE supply_data (
    batch_id VARCHAR(50),
    vendor_name VARCHAR(255),
    product_name VARCHAR(255),
    quantity FLOAT,
    unit VARCHAR(50),
    cost_per_kg FLOAT,
    defect_rate_pct FLOAT,
    procurement_date DATE,
    total_procurement_cost FLOAT,
    procurement_year INT,
    procurement_month INT,
    procurement_day INT,
    procurement_weekday VARCHAR(20)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/day8_time_normalized_supply_data.csv'
INTO TABLE supply_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_records FROM supply_data;

SELECT * FROM supply_data LIMIT 10;

SELECT 
    vendor_name,
    SUM(quantity) AS total_quantity,
    AVG(cost_per_kg) AS avg_cost,
    AVG(defect_rate_pct) AS avg_defect,
    SUM(quantity * cost_per_kg) AS total_cost
FROM supply_data
GROUP BY vendor_name;

SELECT 
    vendor_name,
    SUM(quantity * cost_per_kg) / SUM(quantity) AS weighted_cost,
    AVG(defect_rate_pct) AS avg_defect
FROM supply_data
GROUP BY vendor_name;


SELECT 
    vendor_name,
    AVG(defect_rate_pct) AS avg_defect,
    CASE 
        WHEN AVG(defect_rate_pct) > 5 THEN 'HIGH RISK'
        WHEN AVG(defect_rate_pct) BETWEEN 2 AND 5 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_category
FROM supply_data
GROUP BY vendor_name;

SELECT 
    vendor_name,
    AVG(defect_rate_pct) AS avg_defect,
    AVG(cost_per_kg) AS avg_cost
FROM supply_data
GROUP BY vendor_name
ORDER BY avg_defect ASC, avg_cost ASC
LIMIT 5;

SELECT 
    vendor_name,
    AVG(defect_rate_pct) AS avg_defect,
    AVG(cost_per_kg) AS avg_cost
FROM supply_data
GROUP BY vendor_name
ORDER BY avg_defect DESC
LIMIT 5;

(SELECT 
    'vendor_name',
    'total_quantity',
    'avg_cost',
    'avg_defect',
    'total_cost'
)
UNION ALL
(SELECT 
    vendor_name,
    SUM(quantity),
    AVG(cost_per_kg),
    AVG(defect_rate_pct),
    SUM(quantity * cost_per_kg)
FROM supply_data
GROUP BY vendor_name)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/vendor_performance.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
