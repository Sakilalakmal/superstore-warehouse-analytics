-- =============================================
-- Script: Bronze Layer Data Loading Procedure
-- Description: Loads raw data from CSV files into bronze schema tables
-- Tables: bronze.order_sales, bronze.products
-- Author: Data Engineering Team
-- Date: 2026-03-16
-- =============================================

-- use database superstore_warehouse_analytics
USE superstore_warehouse_analytics ;
Go

-- =============================================
-- Stored Procedure: bronze.load_data
-- Description: Truncates and loads data into bronze layer tables from CSV files
--              Includes error handling and performance tracking
-- =============================================

CREATE OR ALTER PROCEDURE bronze.load_data
AS
BEGIN
    -- Declare variables for time tracking
    DECLARE @ProcStartTime DATETIME = GETDATE();
    DECLARE @TableStartTime DATETIME;
    DECLARE @TableEndTime DATETIME;
    DECLARE @OrderSalesLoadTime INT;
    DECLARE @ProductsLoadTime INT;
    DECLARE @TotalLoadTime INT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    -- Set NOCOUNT ON to prevent extra result sets from interfering with SELECT statements
    SET NOCOUNT ON;

    PRINT '========================================';
    PRINT 'Bronze Layer Data Load Started';
    PRINT 'Start Time: ' + CONVERT(VARCHAR, @ProcStartTime, 120);
    PRINT '========================================';
    PRINT '';

    BEGIN TRY
        -- =============================================
        -- SECTION 1: Load Order Sales Data
        -- =============================================
        PRINT '>> Processing Table: bronze.order_sales';
        SET @TableStartTime = GETDATE();

        --  load data into bronze.order_sales
        PRINT '>> Truncating Table: bronze.order_sales';
        TRUNCATE TABLE bronze.order_sales;

        PRINT '>> Inserting Data Into: bronze.order_sales';
        BULK INSERT bronze.order_sales
        FROM 'D:\DE-DA\superstore-DBWAREHOUSE\orders_sales.csv'
              WITH (
              FIRSTROW = 2,
              FIELDTERMINATOR = ',',
              TABLOCK
           );

        SET @TableEndTime = GETDATE();
        SET @OrderSalesLoadTime = DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime);
        PRINT '>> Successfully loaded bronze.order_sales';
        PRINT '>> Load Time: ' + CAST(@OrderSalesLoadTime AS VARCHAR) + ' ms';
        PRINT '';

        -- =============================================
        -- SECTION 2: Load Products Data
        -- =============================================
        PRINT '>> Processing Table: bronze.products';
        SET @TableStartTime = GETDATE();

        --  load data into bronze.products
        PRINT '>> Truncating Table: bronze.products';
        TRUNCATE TABLE bronze.products;

        PRINT '>> Inserting Data Into: bronze.products';
        BULK INSERT bronze.products
        FROM 'D:\DE-DA\superstore-DBWAREHOUSE\products_clean.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        SET @TableEndTime = GETDATE();
        SET @ProductsLoadTime = DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime);
        PRINT '>> Successfully loaded bronze.products';
        PRINT '>> Load Time: ' + CAST(@ProductsLoadTime AS VARCHAR) + ' ms';
        PRINT '';

        -- =============================================
        -- SECTION 3: Summary
        -- =============================================
        SET @TotalLoadTime = DATEDIFF(MILLISECOND, @ProcStartTime, GETDATE());

        PRINT '========================================';
        PRINT 'Bronze Layer Data Load Completed Successfully';
        PRINT '========================================';
        PRINT 'bronze.order_sales Load Time: ' + CAST(@OrderSalesLoadTime AS VARCHAR) + ' ms';
        PRINT 'bronze.products Load Time: ' + CAST(@ProductsLoadTime AS VARCHAR) + ' ms';
        PRINT 'Total Load Time: ' + CAST(@TotalLoadTime AS VARCHAR) + ' ms';
        PRINT 'End Time: ' + CONVERT(VARCHAR, GETDATE(), 120);
        PRINT '========================================';

    END TRY
    BEGIN CATCH
        -- =============================================
        -- Error Handling Section
        -- =============================================
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT '';
        PRINT '========================================';
        PRINT 'ERROR OCCURRED DURING DATA LOAD';
        PRINT '========================================';
        PRINT 'Error Message: ' + @ErrorMessage;
        PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS VARCHAR);
        PRINT 'Error State: ' + CAST(@ErrorState AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT '========================================';

        -- Re-throw the error to the calling application
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END;
GO

-- use procedure
exec bronze.load_data