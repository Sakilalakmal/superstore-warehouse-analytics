-- create Database

CREATE DATABASE superstore_warehouse_analytics

-- use superstore_warehouse_analytics database
USE superstore_warehouse_analytics;

-- create schema

CREATE SCHEMA bronze ;
CREATE SCHEMA silver ;
CREATE SCHEMA gold ;

-- create bronze order_sales table

IF OBJECT_ID('bronze.order_sales','u') IS NOT NULL
DROP TABLE bronze.order_sales;
go
CREATE TABLE bronze.order_sales (
	order_id			NVARCHAR(50) NOT NULL,
	product_id			NVARCHAR(50) NOT NULL,
	order_date			DATE,
	ship_date			DATE,
	ship_mode			NVARCHAR(50),
	customer_name		NVARCHAR(70) ,
	segment				NVARCHAR(50) ,
	state				NVARCHAR(50) ,
	country				NVARCHAR(50) ,
	market				NVARCHAR(10) ,
	region				NVARCHAR(20) ,
	sales				INT,
	quantity			INT,
	discount			DECIMAL,
	profit				INT,
	shipping_cost		INT,
	order_priority		NVARCHAR(20),
	year				NVARCHAR(10)

)

-- create bronze.product table

IF OBJECT_ID('bronze.products','U') IS NOT NULL
	DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products (
	product_id	NVARCHAR(50) NOT NULL,
	category	NVARCHAR(50),
	sub_category	NVARCHAR(50),
	product_name  NVARCHAR(255)
)

