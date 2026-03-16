-- use superstore_warehouse_analytics
USE superstore_warehouse_analytics;

-- data quality check bronze.products

select * from bronze.products

-- check category types

select
	distinct category
from bronze.products

        -- sub category --
		select distinct sub_category from bronze.products

-- check any duplicate product id (expect 4596 rows)
select 
	distinct product_id
from bronze.products

-- check any unwanted spaces

select 
	*
from bronze.products
WHERE category != TRIM(category) OR sub_category != TRIM(sub_category) OR product_name != TRIM(product_name)

-- load data into silver.products
PRINT 'Cleaned silver.products (SILVER) --'
TRUNCATE TABLE silver.products
PRINT 'Loading data into silver.products...'
INSERT INTO silver.products 
(
	product_id	,
	category	,
	sub_category	,
	product_name  
)
SELECT
	product_id	,
	category	,
	sub_category	,
	product_name  
FROM bronze.products