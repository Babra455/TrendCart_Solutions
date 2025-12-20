CREATE DATABASE trendcart_db;

CREATE TABLE retail_sales (
    transaction_id INT PRIMARY KEY,
    sale_date_text VARCHAR(20),      
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(50),
    quantity INT,
    price_per_unit NUMERIC(10,2),
    cogs NUMERIC(12,2),
    total_sale NUMERIC(12,2)
);

-- Identify duplicates
SELECT transaction_id, COUNT(*)
FROM retail_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;
 
 
UPDATE retail_sales
SET gender = CASE
    WHEN UPPER(TRIM(gender)) IN ('M', 'MALE') THEN 'Male'
    WHEN UPPER(TRIM(gender)) IN ('F', 'FEMALE') THEN 'Female'
    ELSE NULL  
END;

SELECT sale_date_text
FROM retail_sales
WHERE STR_TO_DATE(sale_date_text, '%d/%m/%Y') IS NULL;

ALTER TABLE retail_sales ADD COLUMN sale_date_actual DATE;

SELECT sale_date_text
FROM retail_sales
WHERE sale_date_actual IS NULL;

UPDATE retail_sales
SET sale_date_text = TRIM(sale_date_text);

UPDATE retail_sales
SET sale_date_actual = STR_TO_DATE(sale_date_text, '%m/%d/%Y');

ALTER TABLE retail_sales
DROP COLUMN sale_date_text;

ALTER TABLE retail_sales
RENAME COLUMN sale_date_actual TO sale_date;


ALTER TABLE retail_sales
ADD COLUMN profit DECIMAL(12,2);


UPDATE retail_sales
SET profit = total_sale - cogs;

ALTER TABLE retail_sales
ADD COLUMN sale_year INT,
ADD COLUMN sale_month INT;

UPDATE retail_sales
SET sale_year = YEAR(sale_date),
    sale_month = MONTH(sale_date);
      

SELECT transaction_id, total_sale, cogs, profit
FROM retail_sales
LIMIT 10;


-- MOST VALUABLE CUSTOMER
SELECT 
    customer_id,
    COUNT(transaction_id) AS total_transactions,
    SUM(total_sale) AS total_revenue,
    SUM(profit) AS total_profit
FROM retail_sales
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;


-- Gender
SELECT 
    gender,
    SUM(total_sale) AS revenue,
    SUM(profit) AS profit,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY gender;

-- Age Group
SELECT 
    CASE 
        WHEN age BETWEEN 0 AND 19 THEN '0-19'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,
    SUM(total_sale) AS revenue,
    SUM(profit) AS profit,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY age_group
ORDER BY age_group;

-- Overall profit
SELECT 
    SUM(total_sale) AS total_revenue,
    SUM(cogs) AS total_cost,
    SUM(profit) AS total_profit,
    ROUND((SUM(profit)/SUM(total_sale))*100,2) AS profit_margin_percent
FROM retail_sales;

-- Profit by product category
SELECT 
    category,
    SUM(total_sale) AS revenue,
    SUM(cogs) AS cost,
    SUM(profit) AS profit,
    ROUND((SUM(profit)/SUM(total_sale))*100,2) AS profit_margin_percent
FROM retail_sales
GROUP BY category
ORDER BY profit DESC;

-- Identify categories with high sales AND high profit.
SELECT 
    category,
    SUM(quantity) AS total_units_sold,
    SUM(total_sale) AS revenue,
    SUM(profit) AS profit,
    ROUND((SUM(profit)/SUM(total_sale))*100,2) AS profit_margin_percent
FROM retail_sales
GROUP BY category
ORDER BY profit DESC;



-- Average quantity per transaction
SELECT 
    AVG(quantity) AS avg_quantity_per_transaction,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity
FROM retail_sales;

-- Distribution by quantity ranges
SELECT 
    CASE 
        WHEN quantity = 1 THEN 'Single item'
        WHEN quantity BETWEEN 2 AND 5 THEN 'Small bundle'
        WHEN quantity BETWEEN 6 AND 10 THEN 'Medium bundle'
        ELSE 'Bulk (10+)' 
    END AS purchase_size,
    COUNT(*) AS num_transactions,
    SUM(total_sale) AS revenue,
    SUM(profit) AS profit
FROM retail_sales
GROUP BY purchase_size
ORDER BY num_transactions DESC;

SELECT 
    sale_year,
    sale_month,
    SUM(total_sale) AS revenue,
    SUM(profit) AS profit
FROM retail_sales
GROUP BY sale_year, sale_month
ORDER BY sale_year, sale_month;

-- Monthly trend
SELECT 
    sale_year,
    sale_month,
    SUM(total_sale) AS revenue,
    SUM(profit) AS profit
FROM retail_sales
GROUP BY sale_year, sale_month
ORDER BY sale_year, sale_month;

-- Fix inconsistent category names
UPDATE retail_sales
SET category = 'Clothing'
WHERE category IN ('Cot','Clo','Cloth', 'Clothin', 'Clot');

UPDATE retail_sales
SET category = 'Electronics'
WHERE category IN ('Electr', 'Electron');

UPDATE retail_sales
SET category = 'Beauty'
WHERE category IN ('Beau', 'Beaut', 'Bea');

-- Total sales
SELECT SUM(total_sale) AS total_sales
FROM retail_sales;

-- Average sale per transaction
SELECT AVG(total_sale) AS avg_sale_per_transaction
FROM retail_sales;

SELECT category, SUM(quantity) AS total_quantity_sold
FROM retail_sales
GROUP BY category
ORDER BY total_quantity_sold DESC;

SELECT COUNT(customer_id) AS total_customers
FROM retail_sales;













