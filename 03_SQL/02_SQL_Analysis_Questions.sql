/*
===========================================================
PROJECT      : Ecommerce Data Analyst Project
FILE NAME    : 02_SQL_Analysis_Questions.sql
DATABASE     : ecommerce_db
TABLE        : amazon_ecommerce

OBJECTIVE:
To perform SQL-based analysis on the cleaned ecommerce
dataset and answer business-related questions.

CONCEPTS USED:
SELECT, WHERE, GROUP BY, ORDER BY, LIMIT,
Aggregate Functions, CASE, CTE, Window Functions,
ROW_NUMBER(), LAG()

===========================================================
*/

USE ecommerce_db;


/* =========================================================
   Q1: Find the Top 5 Categories by Total Revenue

   -- SUM() calculates total revenue for each category
   -- GROUP BY groups records category-wise
   -- ORDER BY sorts categories from highest to lowest revenue
   -- LIMIT 5 returns only the top 5 categories
   ========================================================= */

SELECT
    category,
    SUM(final_price) AS total_revenue

FROM ecommerce_db.amazon_ecommerce

GROUP BY category

ORDER BY total_revenue DESC

LIMIT 5;


/* =========================================================
   Q2: Calculate Return Percentage for Each Brand

   -- COUNT(*) calculates total orders for each brand
   -- CASE WHEN counts orders where is_returned is True
   -- SUM() calculates total returned orders
   -- Return percentage = returned orders / total orders * 100
   -- GROUP BY performs the calculation brand-wise
   -- ORDER BY sorts brands by highest return percentage
   ========================================================= */

SELECT
    brand,

    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN is_returned = 'True' THEN 1
            ELSE 0
        END
    ) AS total_returns,

    ROUND(
        SUM(
            CASE
                WHEN is_returned = 'True' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS return_percentage

FROM ecommerce_db.amazon_ecommerce

GROUP BY brand

ORDER BY return_percentage DESC;


/* =========================================================
   Q3: Find sellers whose average seller rating is above 4.5
       but have delayed deliveries above average.

   -- Calculate each seller's average seller rating
   -- Calculate each seller's delayed delivery percentage
   -- Calculate overall delayed delivery percentage
   -- Keep sellers whose average seller rating is above 4.5
   -- Keep sellers whose delayed percentage is above
      the overall delayed percentage
   ========================================================= */

SELECT
    seller_id,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(seller_rating),
        2
    ) AS average_seller_rating,

    SUM(
        CASE
            WHEN delivery_status = 'Delayed'
            THEN 1
            ELSE 0
        END
    ) AS delayed_orders,

    ROUND(
        SUM(
            CASE
                WHEN delivery_status = 'Delayed'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS delayed_percentage

FROM ecommerce_db.amazon_ecommerce

GROUP BY seller_id

HAVING
    AVG(seller_rating) > 4.5

    AND

    (
        SUM(
            CASE
                WHEN delivery_status = 'Delayed'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
    )

    >

    (
        SELECT
            SUM(
                CASE
                    WHEN delivery_status = 'Delayed'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*)

        FROM ecommerce_db.amazon_ecommerce
    )

ORDER BY delayed_percentage DESC;


/* =========================================================
   Q4: Calculate Monthly Sales Growth

   -- STR_TO_DATE() converts purchase_date from TEXT to DATE
   -- DATE_FORMAT() extracts year and month
   -- SUM() calculates monthly revenue
   -- LAG() gets the previous month's revenue
   -- Growth percentage compares current month revenue
      with the previous month's revenue
   -- CTE is used to first calculate monthly revenue
   ========================================================= */

WITH monthly_sales AS (

    SELECT
        DATE_FORMAT(
            STR_TO_DATE(purchase_date, '%Y-%m-%d'),
            '%Y-%m'
        ) AS sales_month,

        SUM(final_price) AS monthly_revenue

    FROM ecommerce_db.amazon_ecommerce

    GROUP BY sales_month
),

sales_with_previous AS (

    SELECT
        sales_month,
        monthly_revenue,

        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue

    FROM monthly_sales
)

SELECT
    sales_month,

    ROUND(
        monthly_revenue,
        2
    ) AS monthly_revenue,

    ROUND(
        previous_month_revenue,
        2
    ) AS previous_month_revenue,

    ROUND(
        (
            (monthly_revenue - previous_month_revenue)
            / previous_month_revenue
        ) * 100,
        2
    ) AS growth_percentage

FROM sales_with_previous

ORDER BY sales_month;


/* =========================================================
   Q5: Find the Top-Selling Subcategory in Each Category

   -- SUM() calculates total sales for each subcategory
   -- GROUP BY groups data by category and subcategory
   -- ROW_NUMBER() assigns a ranking within each category
   -- PARTITION BY creates a separate ranking for each category
   -- ORDER BY sorts subcategories by highest sales
   -- The outer query selects rank 1 from each category
   ========================================================= */

WITH subcategory_sales AS (

    SELECT
        category,
        subcategory,
        SUM(final_price) AS total_sales

    FROM ecommerce_db.amazon_ecommerce

    GROUP BY
        category,
        subcategory
),

ranked_subcategories AS (

    SELECT
        category,
        subcategory,
        total_sales,

        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_sales DESC
        ) AS subcategory_rank

    FROM subcategory_sales
)

SELECT
    category,
    subcategory,
    ROUND(total_sales, 2) AS total_sales

FROM ranked_subcategories

WHERE subcategory_rank = 1

ORDER BY total_sales DESC;


/* =========================================================
   Q6: Identify products where:

   -- Stock is less than 50
   -- Review count is greater than average review count
   -- Rating is greater than 4
   -- AVG(review_count) is calculated for the complete dataset
   ========================================================= */

SELECT
    product_id,
    category,
    subcategory,
    brand,
    stock,
    review_count,
    rating

FROM ecommerce_db.amazon_ecommerce

WHERE
    stock < 50

    AND review_count >
    (
        SELECT
            AVG(review_count)

        FROM ecommerce_db.amazon_ecommerce
    )

    AND rating > 4

ORDER BY review_count DESC;


/* =========================================================
   Q7: Analyze Shipping Performance by City

   -- AVG(shipping_time_days) calculates average shipping time
   -- AVG(rating) calculates average customer rating
   -- COUNT(*) calculates total orders
   -- GROUP BY performs the analysis city-wise
   -- ORDER BY sorts cities by average shipping time
   ========================================================= */

SELECT
    location,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(shipping_time_days),
        2
    ) AS average_shipping_days,

    ROUND(
        AVG(rating),
        2
    ) AS average_customer_rating

FROM ecommerce_db.amazon_ecommerce

GROUP BY location

ORDER BY average_shipping_days;


/* =========================================================
   Q8: Category Analysis Using CTE

   -- CTE first calculates category-level metrics
   -- SUM() calculates total revenue
   -- COUNT(*) calculates total orders
   -- CASE WHEN calculates total returned orders
   -- AVG() calculates average discount
   -- Final SELECT displays category-level metrics
   ========================================================= */

WITH category_analysis AS (

    SELECT
        category,

        COUNT(*) AS total_orders,

        SUM(final_price) AS total_revenue,

        SUM(
            CASE
                WHEN is_returned = 'True'
                THEN 1
                ELSE 0
            END
        ) AS total_returns,

        AVG(discount) AS average_discount

    FROM ecommerce_db.amazon_ecommerce

    GROUP BY category
)

SELECT
    category,

    total_orders,

    ROUND(
        total_revenue,
        2
    ) AS total_revenue,

    total_returns,

    ROUND(
        total_returns * 100.0 / total_orders,
        2
    ) AS return_percentage,

    ROUND(
        average_discount,
        2
    ) AS average_discount

FROM category_analysis

ORDER BY total_revenue DESC;


/* =========================================================
   Q9: Find which payment method contributes the highest
       revenue and lowest return rate.

   -- Calculate revenue and return rate for each payment method
   -- Compare each payment method with the highest revenue
   -- Compare each payment method with the lowest return percentage
   -- Return the payment method satisfying both conditions
   ========================================================= */

WITH payment_analysis AS
(
    SELECT
        payment_method,

        COUNT(*) AS total_orders,

        SUM(final_price) AS total_revenue,

        SUM(
            CASE
                WHEN is_returned = 'True'
                THEN 1
                ELSE 0
            END
        ) AS total_returns,

        ROUND(
            SUM(
                CASE
                    WHEN is_returned = 'True'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS return_percentage

    FROM ecommerce_db.amazon_ecommerce

    GROUP BY payment_method
)

SELECT
    payment_method,

    total_orders,

    ROUND(
        total_revenue,
        2
    ) AS total_revenue,

    total_returns,

    return_percentage

FROM payment_analysis

WHERE
    total_revenue = (
        SELECT
            MAX(total_revenue)
        FROM payment_analysis
    )

    AND

    return_percentage = (
        SELECT
            MIN(return_percentage)
        FROM payment_analysis
    );


/* =========================================================
   Q10: Classify Sellers Based on Performance

   -- CASE is used to classify sellers into performance groups
   -- Seller rating and delayed percentage are used as
      performance conditions
   -- CTE first calculates seller-level performance
   -- Final query applies the classification
   ========================================================= */

WITH seller_performance AS (

    SELECT
        seller_id,

        COUNT(*) AS total_orders,

        AVG(seller_rating) AS average_seller_rating,

        SUM(
            CASE
                WHEN delivery_status = 'Delayed'
                THEN 1
                ELSE 0
            END
        ) AS delayed_orders

    FROM ecommerce_db.amazon_ecommerce

    GROUP BY seller_id
)

SELECT
    seller_id,

    total_orders,

    ROUND(
        average_seller_rating,
        2
    ) AS average_seller_rating,

    delayed_orders,

    ROUND(
        delayed_orders * 100.0 / total_orders,
        2
    ) AS delayed_percentage,

    CASE

        WHEN average_seller_rating >= 4.5
             AND delayed_orders * 100.0 / total_orders <= 20
        THEN 'High Performance'

        WHEN average_seller_rating >= 3.5
             AND delayed_orders * 100.0 / total_orders <= 35
        THEN 'Medium Performance'

        ELSE 'Needs Improvement'

    END AS seller_performance

FROM seller_performance

ORDER BY average_seller_rating DESC;

