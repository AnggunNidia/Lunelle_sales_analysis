/*
========================================================

LUNELLE BEAUTY SALES ANALYSIS

Author  : Anggun Nidia

Database : Beautysales

Description :

This SQL script contains exploratory analysis and business queries used to build 
the Power BI dashboard for the Lunelle Beauty Sales Analysis project.

========================================================
*/

CREATE TABLE products (
    product_code VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    shade VARCHAR(50),
    finish_type VARCHAR(30),
    skin_type_target VARCHAR(30),
    size_ml INT,
    launch_year INT,
    product_status VARCHAR(20),
    production_cost NUMERIC(12,0),
    selling_price NUMERIC(12,0),
    brand VARCHAR(100),
    local_or_import VARCHAR(20),
    halal_certified VARCHAR(10),
    vegan_product VARCHAR(10),
    bpom_registered VARCHAR(10),
    supplier_name VARCHAR(100),
    warehouse_location VARCHAR(50),
    stock_qty INT,
    reorder_point INT,
    rating_average NUMERIC(2,1),
    review_count INT
);

CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    transaction_date VARCHAR(20),
    order_time TIME,
    platform VARCHAR(50),
    order_source VARCHAR(50),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    customer_gender VARCHAR(20),
    customer_age INT,
    city VARCHAR(100),
    province VARCHAR(100),
    membership_tier VARCHAR(20),
    product_code VARCHAR(20),
    quantity INT,
    gross_sales NUMERIC(12,0),
    discount_amount NUMERIC(12,0),
    net_sales NUMERIC(12,0),
    shipping_cost NUMERIC(12,0),
    platform_fee NUMERIC(12,0),
    payment_method VARCHAR(50),
    voucher_used VARCHAR(10),
    campaign_name VARCHAR(100),
    warehouse_origin VARCHAR(100),
    delivery_status VARCHAR(50),
    delivery_days INT,
    customer_rating NUMERIC(2,1),
    returned_flag VARCHAR(10),
    return_reason VARCHAR(255),
    sales_channel_type VARCHAR(50),
    cashier_or_host VARCHAR(100)
);

-- ============================================
-- DATA CHECKING AND CLEANING
-- ============================================

--Product--
select*from products where product_name is null
select product_code,count(*) from products
group by product_code having count(*) >1;

--------------------------------------------
--Transaction--
select*from transactions where transaction_date is null
select transaction_id,count(*) from transactions
group by transaction_id having count(*) >1;
select*from transactions where quantity <0; 
select*from transactions where net_sales <0
select distinct platform from transactions;

alter table transactions add column transaction__date date;
update transactions set transaction__date = to_date (transaction_date,'dd/mm/yyyy');
select transaction_date, transaction__date from transactions limit 10;
alter table transactions drop column transaction_date
alter table transactions rename column transaction__date to transaction_date

 
-- ============================================
-- DATA EXPLORATION
-- ============================================

-- Total Transactions

SELECT
COUNT(*) AS total_transactions
FROM transactions;

------------------------------------------------

-- Total Revenue

SELECT
SUM(net_sales) AS total_revenue
FROM transactions;

------------------------------------------------

-- Total Profit

SELECT
SUM(
net_sales
-
platform_fee
-
(production_cost * quantity)
) AS total_profit
FROM transactions;

------------------------------------------------

-- Revenue by Platform

SELECT
platform,
SUM(net_sales) AS revenue
FROM transactions
GROUP BY platform
ORDER BY revenue DESC;

------------------------------------------------

-- Revenue by Category

SELECT
category,
SUM(net_sales) AS revenue
FROM transactions
GROUP BY category
ORDER BY revenue DESC;

-- ============================================
-- SALES PERFORMANCE
-- ============================================

SELECT

DATE_TRUNC('month',transaction_date) AS month,

SUM(net_sales) AS revenue,

SUM(
net_sales
-
platform_fee
-
(production_cost*quantity)
) AS profit

FROM transactions

GROUP BY month

ORDER BY month;

-- ============================================
-- CAMPAIGN PERFORMANCE
-- ============================================

SELECT

campaign_name,

SUM(net_sales) AS revenue,

SUM(
net_sales
-
platform_fee
-
(production_cost*quantity)
) AS profit

FROM transactions

GROUP BY campaign_name

ORDER BY profit DESC;

-- ============================================
-- PLATFORM PERFORMANCE
-- ============================================

SELECT

platform,

COUNT(transaction_id) AS total_transactions,

SUM(quantity) AS quantity_sold,

SUM(net_sales) AS revenue,

ROUND(AVG(customer_rating),2) AS average_rating

FROM transactions

GROUP BY platform

ORDER BY revenue DESC;

-- ============================================
-- RETURN ANALYSIS
-- ============================================

SELECT

return_reason,

COUNT(*) AS total_return

FROM transactions

WHERE returned_flag='Yes'

GROUP BY return_reason

ORDER BY total_return DESC;

SELECT

category,

COUNT(*) AS total_return

FROM transactions

WHERE returned_flag='Yes'

GROUP BY category

ORDER BY total_return DESC;

SELECT

ROUND(

COUNT(
CASE
WHEN returned_flag='Yes'
THEN 1
END
)::numeric

/

COUNT(*)::numeric

*100

,2)

AS return_rate

FROM transactions;

-- ============================================
-- CUSTOMER ANALYSIS
-- ============================================

SELECT

membership_tier,

COUNT(DISTINCT customer_id) AS total_customer,

SUM(net_sales) AS revenue

FROM transactions

GROUP BY membership_tier

ORDER BY revenue DESC;

SELECT

CASE

WHEN age <20 THEN '<20'

WHEN age BETWEEN 20 AND 29 THEN '20-29'

WHEN age BETWEEN 30 AND 39 THEN '30-39'

WHEN age BETWEEN 40 AND 49 THEN '40-49'

ELSE '50+'

END AS age_group,

SUM(net_sales) AS revenue

FROM transactions

GROUP BY age_group

ORDER BY age_group;

SELECT

province,

SUM(net_sales) AS revenue

FROM transactions

GROUP BY province

ORDER BY revenue DESC;

SELECT

payment_method,

SUM(net_sales) AS revenue

FROM transactions

GROUP BY payment_method

ORDER BY revenue DESC;


