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

select * from gold.fact_order_sales;

-- shipping delays by state
WITH avg_days_shipping AS (
	SELECT
		 ship_mode,
		 AVG(shipping_days) AS avg_days
	FROM gold.fact_order_sales
		GROUP BY ship_mode
	),
	avg_days_calc AS 
	(SELECT
		fact.order_id,
		fact.state,
		fact.ship_mode,
		fact.shipping_days,
		avg_days.avg_days,
		CASE WHEN fact.shipping_days > avg_days.avg_days  THEN 1 ELSE 0  END AS late_ship_flag
	FROM gold.fact_order_sales AS fact
		LEFT JOIN avg_days_shipping AS avg_days
		ON fact.ship_mode = avg_days.ship_mode
	)
	SELECT
		state,
		COUNT(order_id) AS total_orders,
		SUM(late_ship_flag) AS late_shipment_count,
		CONCAT(SUM(late_ship_flag) * 100 / NULLIF(COUNT(order_id),0),'%') AS late_percentage
	FROM avg_days_calc 
		GROUP BY state
		ORDER BY SUM(late_ship_flag) DESC;

-- shipping performance trend over time

WITH month_avg AS(
	SELECT
		DATETRUNC(MONTH,order_date) AS months,
		AVG(shipping_days) AS avg_day
	FROM gold.fact_order_sales
	GROUP BY DATETRUNC(MONTH,order_date)
	),
	differ AS (
	SELECT
		fact.order_id,
		fact.shipping_days,
		DATETRUNC(MONTH,fact.order_date)fact_month,
		avg_month.avg_day,
		CASE WHEN fact.shipping_days > avg_month.avg_day THEN 1 ELSE 0 END AS late_flag
	FROM gold.fact_order_sales AS fact
		LEFT JOIN month_avg AS avg_month
		ON DATETRUNC(MONTH,fact.order_date) = avg_month.months
	)
	SELECT
		fact_month,
		COUNT(order_id) AS order_count,
		SUM(late_flag) AS delay_orders,
		CONCAT(ROUND(SUM(late_flag) * 100 / NULLIF(COUNT(order_id),0),2),'%') AS late_rate
	FROM differ
	GROUP BY fact_month
	ORDER BY fact_month ASC
