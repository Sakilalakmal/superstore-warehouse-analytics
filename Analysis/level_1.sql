-- use superstore_warehouse_analytics
USE superstore_warehouse_analytics;
GO

-- Total Sales

SELECT SUM(sales) AS total_sales FROM gold.fact_order_sales

-- What is the total profit generated?

SELECT SUM(profit) AS total_profit FROM gold.fact_order_sales

-- How many orders were placed in total?
SELECT COUNT(*) AS total_orders FROM gold.fact_order_sales 

-- What is the total quantity of products sold?
SELECT SUM(quantity)AS total_quantity  FROM gold.fact_order_sales

-- What are the total sales by year
SELECT
	year,
	SUM(sales) AS sales_per_year
FROM gold.fact_order_sales
GROUP BY year

-- What are the total profits by year?
SELECT
	year,
	SUM(profit) AS profit_per_year
FROM gold.fact_order_sales
GROUP BY year

-- Which market generates the most sales?

SELECT TOP(1)
market,
	SUM(sales) AS sales_per_market
FROM gold.fact_order_sales
	GROUP BY market
	ORDER BY SUM(sales) DESC

-- Which region generates the highest sales
SELECT TOP(1)
region,
	SUM(sales) AS sales_per_region
FROM gold.fact_order_sales
	GROUP BY region
	ORDER BY SUM(sales) DESC

-- What are the total sales by customer segment
SELECT
	segment,
	SUM(sales) AS total_sales_per_segment
FROM gold.fact_order_sales
	GROUP BY segment
	ORDER BY SUM(sales) DESC

-- Which shipping mode is used the most
SELECT
	ship_mode,
	COUNT(*) count_per_ship_mode
FROM gold.fact_order_sales
	GROUP BY ship_mode
	ORDER BY COUNT(*) DESC

-- What is the average shipping time for orders
SELECT
	AVG(shipping_days) AS avg_shipping_days
FROM gold.fact_order_sales

-- How many orders are profitable vs not profitable
SELECT
	SUM(is_profitable) profitable,
	COUNT(CASE WHEN is_profitable = 0 THEN 1 END) AS non_profit
FROM gold.fact_order_sales

-- How many high priority orders exist

SELECT
	SUM(is_high_priority) AS high_prio_count
FROM gold.fact_order_sales

-- Which product category generates the highest sales

SELECT
	prod.category,
	SUM(sales) AS category_sales
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY prod.category
	ORDER BY SUM(sales) DESC

-- What are the top 10 customers by sales revenue

SELECT TOP(10)
	fact.customer_name,
	SUM(fact.net_revenue) AS revenue
FROM gold.fact_order_sales fact
GROUP BY fact.customer_name
ORDER BY SUM(fact.net_revenue) DESC;

SELECT * FROM (
SELECT
	fact.customer_name,
	SUM(fact.net_revenue) AS revenue,
	RANK() OVER(ORDER BY SUM(fact.net_revenue) DESC) AS customer_rank
FROM gold.fact_order_sales fact
GROUP BY fact.customer_name
)t
WHERE customer_rank <= 10;

-- Which segmemnt have most high prority orders
SELECT
	segment,
	SUM(is_high_priority) AS high_prio_count
FROM gold.fact_order_sales
	GROUP BY segment
	ORDER BY SUM(is_high_priority) DESC

-- last order date and last ship date
SELECT
	MAX(order_date) AS latest_order_date,
	MAX(ship_date) AS latest_ship_date
FROM gold.fact_order_sales;

-- how many orders per subcategory and total net revenue for each subcategory

SELECT
	prod.sub_category,
	COUNT(fact.order_id) order_count,
	SUM(fact.net_revenue) AS total_revenue
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
GROUP BY prod.sub_category
ORDER BY COUNT(fact.order_id) DESC , SUM(fact.net_revenue) DESC


-- how many orders per order_priority

SELECT
	order_priority,
	COUNT(*) order_count
FROM gold.fact_order_sales
GROUP BY order_priority

-- most selling product name

SELECT TOP(1)
	sub_product_id,
	prod2.product_name,
	prod_count,
	prod2.category,
	prod2.sub_category
FROM (
SELECT
	fact.product_id AS sub_product_id,
	COUNT(*) AS prod_count
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY fact.product_id
	) t
LEFT JOIN gold.dim_products AS prod2
ON sub_product_id = prod2.product_id
ORDER BY prod_count DESC

select * from gold.fact_order_sales

select * from gold.dim_products