-- use superstore_warehouse_analytics
USE superstore_warehouse_analytics;

-- data quality check asnwer should be (6591)
select 
	distinct order_id 
from bronze.order_sales


-- check unwanted space
-- expected no result

select 
*
from bronze.order_sales
	where ship_mode != TRIM(ship_mode) 
	OR customer_name != TRIM(customer_name) 
	OR segment != TRIM(segment)
	OR state != TRIM(state)
	OR country != TRIM(country)
	OR market != TRIM(market)
	OR region != TRIM(region)
	OR order_priority != TRIM(order_priority)

-- check any product_id in order_sales table exists that didn't exists on product table (no result)
select
	prd.product_id 
from bronze.products AS prd
	LEFT JOIN bronze.order_sales AS ord
	ON prd.product_id = ord.product_id
	WHERE ord.product_id IS NULL

-- check is there any order_id or product_id NULL (no result)
select *
from bronze.order_sales
WHERE order_id IS NULL OR product_id IS NULL

-- load data into silver.order_sales
PRINT 'Cleaned silver.order_sales (SILVER) --'
TRUNCATE TABLE silver.order_sales
PRINT 'Loading data into silver.order_sales...'
INSERT INTO silver.order_sales 
(
	order_id			,
	product_id			,
	order_date			,
	ship_date			,
	ship_mode			,
	customer_name		 ,
	segment				 ,
	state				 ,
	country				 ,
	market				 ,
	region				 ,
	sales				,
	quantity			,
	discount			,
	profit				,
	shipping_cost		,
	order_priority		,
	year				
)
SELECT
	order_id			,
	product_id			,
	order_date			,
	ship_date			,
	ship_mode			,
	customer_name		 ,
	segment				 ,
	state				 ,
	country				 ,
	market				 ,
	region				 ,
	sales				,
	quantity			,
	discount 		,
	profit				,
	shipping_cost		,
	order_priority		,
	year				
FROM bronze.order_sales

-- silver.order_sales data check

select * from silver.order_sales