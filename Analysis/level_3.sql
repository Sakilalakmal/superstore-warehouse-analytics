-- use superstore_warehouse_analytics
USE superstore_warehouse_analytics;
GO 

-- 1 Which top 3 products generate the highest sales in each category
SELECT 
	product_id1,
	category1,
	prod2.product_name,
	total_sales
FROM (
SELECT
	prod.category AS category1,
	prod.product_id AS product_id1,
	SUM(fact.sales) AS total_sales,
	RANK() OVER(PARTITION BY prod.category ORDER BY SUM(fact.sales) DESC) AS rank_product
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY prod.category , prod.product_id
	)t
	LEFT JOIN gold.dim_products AS prod2
	ON product_id1 = prod2.product_id
	WHERE rank_product <= 3
	
-- 2 Who are the top customers by lifetime value (CLV)?
SELECT
	customer_name,
	SUM(sales) AS total_sales_per_customer,
	RANK() OVER(ORDER BY SUM(sales) DESC) AS customer_rank
FROM gold.fact_order_sales
GROUP BY customer_name

-- 3 Which regions show the fastest sales growth over time
SELECT 
	region,
	year,
	total_sales,
	prev_year_sales,
	total_sales - prev_year_sales AS year_performance,
	CASE WHEN prev_year_sales = 0 OR prev_year_sales IS NULL THEN NULL 
	     ELSE (total_sales - prev_year_sales) * 100 / prev_year_sales
	END AS growth_percentage,
	CASE WHEN total_sales - prev_year_sales > 0 THEN 'good performance'
		 WHEN prev_year_sales IS NULL THEN NULL
		 ELSE 'bad performance' END AS performance_seg
FROM (
SELECT
	region,
	year,
	SUM(sales) AS total_sales ,
	LAG(SUM(sales)) OVER(PARTITION BY region ORDER BY year ASC) AS prev_year_sales
FROM gold.fact_order_sales
GROUP BY region ,year	

) t
WHERE (total_sales - prev_year_sales) * 100 / prev_year_sales >= 90
ORDER BY region ,year

-- Which product sub-categories are frequently sold in large quantities but generate low profit?

SELECT
	prod.sub_category,
	SUM(fact.quantity) AS total_quantity,
	SUM(fact.profit) AS total_profits,
	SUM(fact.profit) / NULLIF(SUM(fact.quantity),0) AS profit_per_unit
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY prod.sub_category
	HAVING SUM(fact.profit) / NULLIF(SUM(fact.quantity),0) < 20

-- Which shipping modes are most efficient in terms of profit after shipping cost

SELECT
	ship_mode,
	SUM(profit) AS total_profit,
	SUM(shipping_cost) AS total_shipping_cost,
	SUM(profit) - SUM(shipping_cost)  AS balance
FROM gold.fact_order_sales
	GROUP BY ship_mode
	HAVING SUM(profit) - SUM(shipping_cost) > 0

-- Which customers show declining purchase behavior over time (YEAR)

WITH prev_yr_sales_amount AS (
SELECT
	customer_name,
	year,
	SUM(sales) AS cust_total_sales,
	LAG(SUM(sales)) OVER(PARTITION BY customer_name ORDER BY year ASC) AS prev_yr_sales
FROM gold.fact_order_sales
	GROUP BY year , customer_name

)
SELECT 
	customer_name,
	COUNT(*) churn_count
FROM prev_yr_sales_amount
	WHERE cust_total_sales < prev_yr_sales
	GROUP BY customer_name
	ORDER BY COUNT(*) DESC

-- What is the repeat purchase rate of customers

WITH customer_orders AS (
    SELECT
        customer_name,
        COUNT(DISTINCT order_id) AS order_count
    FROM gold.fact_order_sales
    GROUP BY customer_name
),
repeat_customers AS (
    SELECT COUNT(*) AS repeat_count
    FROM customer_orders
    WHERE order_count > 1
),
total_customers AS (
    SELECT COUNT(*) AS total_count
    FROM customer_orders
)
SELECT 
    repeat_count * 100.0 / total_count AS repeat_purchase_rate
FROM repeat_customers, total_customers;

-- differ between total sales and net_revenue
SELECT
	SUM(sales) AS total_sales,
	SUM(net_revenue) AS total_net_revenue,
	SUM(sales) - SUM(net_revenue) AS balance_revenue
FROM gold.fact_order_sales

-- which product has lowest sales in per market
SELECT * FROM (
	SELECT
		fact.market,
		prod.product_name,
		SUM(sales) AS total_sales,
		ROW_NUMBER() OVER(PARTITION BY fact.market ORDER BY SUM(sales) ASC) prod_rank
	FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY fact.market , prod.product_name
)t
WHERE prod_rank = 1
