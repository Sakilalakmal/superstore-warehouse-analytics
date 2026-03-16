-- =========================================== Medium Level Analysis Questions ==========================================================

-- use superstore_warehouse_analytics
USE superstore_warehouse_analytics;
GO 

-- 1 Which top 5 products generate the highest profit?

SELECT
	sub_product_id,
	prod2.product_name,
	prod2.category,
	total_profit
FROM (
SELECT TOP(5)
	prod.product_id AS sub_product_id,
	SUM(fact.profit) AS total_profit
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY prod.product_id
	ORDER BY SUM(fact.profit) DESC
	) t
	LEFT JOIN gold.dim_products AS prod2
	ON sub_product_id = prod2.product_id

-- 2 Which states generate the highest profit margin?

SELECT
	fact.state AS state,
	SUM(fact.profit) profit,
	SUM(fact.sales) AS sales,
	SUM(fact.profit) * 100 / NULLIF(SUM(fact.sales),0) AS profit_margin
FROM gold.fact_order_sales AS fact
	GROUP BY fact.state
ORDER BY SUM(fact.profit) * 100 / NULLIF(SUM(fact.sales),0) DESC

-- 3 Which product categories generate the most profits

SELECT
	prod.category,
	SUM(profit) AS total_profit
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY prod.category
	ORDER BY SUM(profit) DESC

-- 4 Which customers generate high sales but low profit
SELECT * FROM (
SELECT 
    customer_name,
	SUM(sales) AS sales,
	SUM(profit) AS total_profit,
	SUM(profit) * 100 / NULLIF(SUM(sales),0) AS profit_margin
FROM gold.fact_order_sales AS fact
GROUP BY customer_name
) t
WHERE profit_margin < 5 AND sales >= 5000
ORDER BY sales DESC

-- 5 Which ship mode has the fastest average delivery time

SELECT
	ship_mode,
	AVG(shipping_days) AS avg_days
FROM gold.fact_order_sales AS fact
group by ship_mode
ORDER BY AVG(shipping_days)

-- 6 Which regions have the highest average order value (AOV)
SELECT
	region,
	SUM(sales) AS total_sales,
	COUNT(*) AS order_count,
	SUM(sales) / COUNT(*) AS aov
FROM gold.fact_order_sales 
	GROUP BY region
	ORDER BY SUM(sales) / COUNT(*) DESC

-- 7 Which segments receive the most discounts
SELECT
	segment,
	AVG(discount) AS avg_discount
FROM gold.fact_order_sales
GROUP BY segment
ORDER BY AVG(discount) DESC

-- 8 Which product sub-categories generate the highest sales (> 50000)
SELECT * FROM (
SELECT
	prod.sub_category,
	SUM(fact.sales) AS total_sales
FROM gold.fact_order_sales AS fact
	LEFT JOIN gold.dim_products AS prod
	ON fact.product_id = prod.product_id
	GROUP BY prod.sub_category
) t
WHERE total_sales > 50000
ORDER BY total_sales DESC

-- 9 Which year had the highest profit growth compared to the previous year
SELECT *,
total_profit - prev_profit AS profit_difference,
CASE WHEN prev_profit IS NULL OR prev_profit = 0 THEN NULL
     ELSE CONCAT((total_profit - prev_profit) * 100 / prev_profit,'%')
END  AS growth_percentage
FROM (
SELECT
	year,
	SUM(profit) AS total_profit,
	LAG(SUM(profit)) OVER(ORDER BY year) prev_profit
FROM gold.fact_order_sales 
GROUP BY year
) t

-- 🔟 Which regions have the highest shipping costs relative to sales?

SELECT
	region,
	SUM(shipping_cost) AS shipping_cost,
	SUM(sales) AS total_sales,
	COUNT(*) AS order_count,
	CONCAT(SUM(shipping_cost) * 100 / NULLIF(SUM(sales),0),'%') AS ship_cost_percentage
FROM gold.fact_order_sales
	GROUP BY region

select * from gold.fact_order_sales