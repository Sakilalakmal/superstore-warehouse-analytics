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
	     ELSE CONCAT((total_sales - prev_year_sales) * 100 / prev_year_sales,'%')
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
WHERE CONCAT((total_sales - prev_year_sales) * 100 / prev_year_sales,'%') >= '90%'
ORDER BY region ,year