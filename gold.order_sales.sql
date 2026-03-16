-- use superstore_warehouse_analytics
USE superstore_warehouse_analytics;
GO
-- create view

CREATE OR ALTER VIEW gold.fact_order_sales AS
SELECT
	order_id,
	product_id,
	customer_name,
	ship_mode,
	segment,
	state,
	country,
	market,
	region,
	sales,
	quantity,
	discount,
	profit,
	shipping_cost,
	order_priority,
	order_date,
	ship_date,
	year,
	DATEDIFF(day,order_date,ship_date) AS shipping_days,
	CASE WHEN profit > 0 THEN 1 ELSE 0 END is_profitable,
	CASE WHEN order_priority IN ('Critical','High') THEN 1 ELSE 0 END is_high_priority,
	sales - shipping_cost AS net_revenue
FROM silver.order_sales;


-- gold.products table

CREATE OR ALTER VIEW gold.dim_products AS 
SELECT
	product_id,
	category,
	sub_category,
	product_name
FROM silver.products;