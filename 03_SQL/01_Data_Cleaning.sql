/*
===========================================================
PROJECT      : Ecommerce Data Analyst Project
FILE NAME    : 01_Data_Cleaning.sql
DATABASE     : ecommerce_db
TABLE        : amazon_ecommerce

DATASET      : amazon_ecommerce_1M.csv
TOTAL ROWS   : 1,000,000

OBJECTIVE:
To validate and clean the imported ecommerce dataset
before performing SQL analysis.

NOTE:
This file contains data-quality checks only.
No unnecessary DELETE or UPDATE operations are performed.
===========================================================
*/

/* =========================================================
   STEP 1: Create Database
   ========================================================= */

CREATE DATABASE IF NOT EXISTS ecommerce_db;

USE ecommerce_db;


/* =========================================================
/* =========================================================
   STEP 2: Create Ecommerce Table
   ========================================================= */

CREATE TABLE amazon_ecommerce (
    user_id TEXT,
    product_id TEXT,
    category TEXT,
    subcategory TEXT,
    brand TEXT,
    price DOUBLE,
    discount DOUBLE,
    final_price DOUBLE,
    rating DOUBLE,
    review_count INT,
    stock INT,
    seller_id TEXT,
    seller_rating DOUBLE,
    purchase_date TEXT,
    shipping_time_days INT,
    location TEXT,
    device TEXT,
    payment_method TEXT,
    is_returned TEXT,
    delivery_status TEXT
);

-- Data Cleaning Step 3: Check for Duplicate Records
-- COUNT(*) counts all records in the table
-- COUNT(DISTINCT ...) counts unique combinations of important columns
-- The comparison helps identify whether duplicate records may exist

SELECT
    COUNT(*) AS total_rows,
    COUNT(
        DISTINCT CONCAT_WS(
            '|',
            user_id,
            product_id,
            category,
            subcategory,
            brand,
            price,
            discount,
            final_price,
            rating,
            review_count,
            stock,
            seller_id,
            seller_rating,
            purchase_date,
            shipping_time_days,
            location,
            device,
            payment_method,
            is_returned,
            delivery_status
        )
    ) AS unique_rows
FROM ecommerce_db.amazon_ecommerce;



-- Data Cleaning Step 4: Check for NULL and Blank Values
-- COUNT(*) gives the total number of records
-- SUM(CASE WHEN ... IS NULL) counts NULL values
-- TRIM() removes extra spaces before checking blank values
-- This check helps identify missing data in each column

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN user_id IS NULL OR TRIM(user_id) = '' THEN 1 ELSE 0 END) AS user_id_missing,
    SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS product_id_missing,
    SUM(CASE WHEN category IS NULL OR TRIM(category) = '' THEN 1 ELSE 0 END) AS category_missing,
    SUM(CASE WHEN subcategory IS NULL OR TRIM(subcategory) = '' THEN 1 ELSE 0 END) AS subcategory_missing,
    SUM(CASE WHEN brand IS NULL OR TRIM(brand) = '' THEN 1 ELSE 0 END) AS brand_missing,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_missing,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS discount_missing,
    SUM(CASE WHEN final_price IS NULL THEN 1 ELSE 0 END) AS final_price_missing,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_missing,
    SUM(CASE WHEN review_count IS NULL THEN 1 ELSE 0 END) AS review_count_missing,
    SUM(CASE WHEN stock IS NULL THEN 1 ELSE 0 END) AS stock_missing,
    SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id) = '' THEN 1 ELSE 0 END) AS seller_id_missing,
    SUM(CASE WHEN seller_rating IS NULL THEN 1 ELSE 0 END) AS seller_rating_missing,
    SUM(CASE WHEN purchase_date IS NULL OR TRIM(purchase_date) = '' THEN 1 ELSE 0 END) AS purchase_date_missing,
    SUM(CASE WHEN shipping_time_days IS NULL THEN 1 ELSE 0 END) AS shipping_time_missing,
    SUM(CASE WHEN location IS NULL OR TRIM(location) = '' THEN 1 ELSE 0 END) AS location_missing,
    SUM(CASE WHEN device IS NULL OR TRIM(device) = '' THEN 1 ELSE 0 END) AS device_missing,
    SUM(CASE WHEN payment_method IS NULL OR TRIM(payment_method) = '' THEN 1 ELSE 0 END) AS payment_method_missing,
    SUM(CASE WHEN is_returned IS NULL OR TRIM(is_returned) = '' THEN 1 ELSE 0 END) AS is_returned_missing,
    SUM(CASE WHEN delivery_status IS NULL OR TRIM(delivery_status) = '' THEN 1 ELSE 0 END) AS delivery_status_missing

FROM ecommerce_db.amazon_ecommerce;





-- Data Cleaning Step 5: Check Category Values
-- DISTINCT returns each unique category value
-- COUNT(*) shows how many records belong to each category
-- GROUP BY groups records according to category
-- ORDER BY sorts categories alphabetically for easy inspection

SELECT
    category,
    COUNT(*) AS record_count
FROM ecommerce_db.amazon_ecommerce
GROUP BY category
ORDER BY category;



-- Data Cleaning Step 6: Check Subcategory Values
-- DISTINCT values are grouped through GROUP BY
-- COUNT(*) shows the number of records for each subcategory
-- ORDER BY sorts the values alphabetically for easy inspection
-- This check helps identify spelling or naming inconsistencies

SELECT
    subcategory,
    COUNT(*) AS record_count
FROM ecommerce_db.amazon_ecommerce
GROUP BY subcategory
ORDER BY subcategory;




-- Data Cleaning Step 7: Check Brand Values
-- GROUP BY identifies each unique brand
-- COUNT(*) shows the number of records for each brand
-- ORDER BY sorts brands alphabetically for easy inspection
-- This check helps identify spelling, case, or naming inconsistencies

SELECT
    brand,
    COUNT(*) AS record_count
FROM ecommerce_db.amazon_ecommerce
GROUP BY brand
ORDER BY brand;






-- Data Cleaning Step 8: Check Numeric Data Quality
-- MIN() identifies the lowest value in each numeric column
-- MAX() identifies the highest value in each numeric column
-- AVG() shows the average value for important numeric fields
-- This check helps identify negative or out-of-range values

SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount,
    MIN(final_price) AS min_final_price,
    MAX(final_price) AS max_final_price,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    MIN(review_count) AS min_review_count,
    MAX(review_count) AS max_review_count,
    MIN(stock) AS min_stock,
    MAX(stock) AS max_stock,
    MIN(seller_rating) AS min_seller_rating,
    MAX(seller_rating) AS max_seller_rating,
    MIN(shipping_time_days) AS min_shipping_days,
    MAX(shipping_time_days) AS max_shipping_days
FROM ecommerce_db.amazon_ecommerce;




-- Data Cleaning Step 9: Validate Final Price Calculation
-- The expected final price is calculated using price and discount
-- ABS() calculates the absolute difference between expected and actual final price
-- ROUND() avoids minor decimal/precision differences
-- The query counts records where the actual final price
-- does not match the expected discounted price

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN ABS(
                final_price -
                (price - (price * discount / 100))
            ) > 0.01
            THEN 1
            ELSE 0
        END
    ) AS inconsistent_final_price_rows

FROM ecommerce_db.amazon_ecommerce;




-- Data Cleaning Step 10: Inspect Price and Discount Relationship
-- SELECT displays the actual values stored in the dataset
-- LIMIT 20 shows a small sample instead of scanning the full result visually
-- This helps us understand how final_price is actually calculated

SELECT
    price,
    discount,
    final_price
FROM ecommerce_db.amazon_ecommerce
LIMIT 20;




-- Data Cleaning Step 10: Measure Final Price Difference
-- This query calculates the difference between:
-- 1. Actual final_price stored in the dataset
-- 2. Expected price after applying the discount
--
-- ABS() gives the absolute difference.
-- ROUND() makes the values easier to read.
-- ORDER BY shows the records with the largest difference first.
-- LIMIT 20 displays only the 20 largest differences for inspection.

SELECT
    price,
    discount,
    final_price,

    ROUND(
        price - (price * discount / 100),
        2
    ) AS expected_final_price,

    ROUND(
        ABS(
            final_price -
            (price - (price * discount / 100))
        ),
        2
    ) AS price_difference

FROM ecommerce_db.amazon_ecommerce

ORDER BY price_difference DESC

LIMIT 20;



-- Data Cleaning Step 11: Check Device Values
-- GROUP BY identifies each unique device type
-- COUNT(*) shows how many records belong to each device
-- ORDER BY sorts the device values alphabetically
-- This check helps identify spelling or naming inconsistencies

SELECT
    device,
    COUNT(*) AS record_count
FROM ecommerce_db.amazon_ecommerce
GROUP BY device
ORDER BY device;



-- Data Cleaning Step 12: Check Payment Method Values
-- GROUP BY identifies each unique payment method
-- COUNT(*) shows how many records belong to each payment method
-- ORDER BY sorts the payment methods alphabetically
-- This check helps identify spelling or naming inconsistencies

SELECT
    payment_method,
    COUNT(*) AS record_count
FROM ecommerce_db.amazon_ecommerce
GROUP BY payment_method
ORDER BY payment_method;



-- Data Cleaning Step 13: Check Delivery Status Values
-- GROUP BY identifies each unique delivery status
-- COUNT(*) shows how many records belong to each status
-- ORDER BY sorts the status values alphabetically
-- This check helps identify spelling or naming inconsistencies

SELECT
    delivery_status,
    COUNT(*) AS record_count
FROM ecommerce_db.amazon_ecommerce
GROUP BY delivery_status
ORDER BY delivery_status;


-- Data Cleaning Step 14: Check Location Values
-- GROUP BY identifies each unique location
-- COUNT(*) shows how many records belong to each location
-- ORDER BY sorts locations alphabetically
-- This check helps identify spelling or naming inconsistencies

SELECT
    location,
    COUNT(*) AS record_count
FROM ecommerce_db.amazon_ecommerce
GROUP BY location
ORDER BY location;



-- Data Cleaning Step 15: Validate Purchase Date
-- STR_TO_DATE() converts the TEXT date into a proper date format
-- '%d-%m-%Y' represents Day-Month-Year
-- IS NULL identifies dates that cannot be converted
-- This check helps identify invalid date values

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN STR_TO_DATE(purchase_date, '%d-%m-%Y') IS NULL
            THEN 1
            ELSE 0
        END
    ) AS invalid_date_rows,

    MIN(
        STR_TO_DATE(purchase_date, '%d-%m-%Y')
    ) AS earliest_date,

    MAX(
        STR_TO_DATE(purchase_date, '%d-%m-%Y')
    ) AS latest_date

FROM ecommerce_db.amazon_ecommerce;


-- Data Cleaning Step 16: Check Logical Consistency
-- This query checks whether important business rules are satisfied:
--
-- 1. final_price should not be greater than price
-- 2. discount should be between 0 and 100
-- 3. rating should be between 1 and 5
-- 4. seller_rating should be between 1 and 5
-- 5. review_count should not be negative
-- 6. stock should not be negative
-- 7. shipping_time_days should be greater than 0
--
-- Each SUM(CASE WHEN...) counts records that violate a rule.

SELECT

    SUM(
        CASE
            WHEN final_price > price THEN 1
            ELSE 0
        END
    ) AS final_price_greater_than_price,

    SUM(
        CASE
            WHEN discount < 0 OR discount > 100 THEN 1
            ELSE 0
        END
    ) AS invalid_discount,

    SUM(
        CASE
            WHEN rating < 1 OR rating > 5 THEN 1
            ELSE 0
        END
    ) AS invalid_rating,

    SUM(
        CASE
            WHEN seller_rating < 1 OR seller_rating > 5 THEN 1
            ELSE 0
        END
    ) AS invalid_seller_rating,

    SUM(
        CASE
            WHEN review_count < 0 THEN 1
            ELSE 0
        END
    ) AS negative_review_count,

    SUM(
        CASE
            WHEN stock < 0 THEN 1
            ELSE 0
        END
    ) AS negative_stock,

    SUM(
        CASE
            WHEN shipping_time_days <= 0 THEN 1
            ELSE 0
        END
    ) AS invalid_shipping_days

FROM ecommerce_db.amazon_ecommerce;



/*
===========================================================
DATA CLEANING CHECK COMPLETED
===========================================================
*/

