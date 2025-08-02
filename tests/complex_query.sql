-- Database prefix: company_data
--
-- Three sample tables for demonstrating complex queries:
-- 1. company_data.products: Information about products.
-- 2. company_data.sales: Transactional sales data.
-- 3. company_data.customers: Customer information.

-- ===================================================================
-- Table Schemas
-- ===================================================================

CREATE TABLE company_data.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE company_data.sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    region VARCHAR(50) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES company_data.products(product_id),
    FOREIGN KEY (customer_id) REFERENCES company_data.customers(customer_id)
);

CREATE TABLE company_data.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- ===================================================================
-- Complex Queries with Window Functions
-- ===================================================================

-- Query 1: Customer Sales Performance and Rank
-- Ranks customers by their total sales within a specific region (e.g., 'North America')
-- and provides their previous month's sales for comparison.

SELECT
    -- Select the customer's name and total sales for the month.
    c.customer_name,
    EXTRACT(YEAR FROM s.sale_date) AS sale_year,
    EXTRACT(MONTH FROM s.sale_date) AS sale_month,
    SUM(p.price * s.quantity) AS total_sales,

    -- Use DENSE_RANK to rank customers within the region for that month.
    -- DENSE_RANK assigns the same rank to rows with the same value and no gaps.
    DENSE_RANK() OVER (
        PARTITION BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
        ORDER BY SUM(p.price * s.quantity) DESC
    ) AS monthly_rank,

    -- Use LAG to get the total sales from the previous month for the same customer.
    -- The PARTITION BY customer_id ensures we're looking at the same customer's history.
    LAG(SUM(p.price * s.quantity), 1, 0) OVER (
        PARTITION BY c.customer_id
        ORDER BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
    ) AS previous_month_sales
FROM
    company_data.sales AS s
JOIN
    company_data.products AS p ON s.product_id = p.product_id
JOIN
    company_data.customers AS c ON s.customer_id = c.customer_id
WHERE
    s.region = 'North America'
GROUP BY
    c.customer_name, c.customer_id, EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
ORDER BY
    c.customer_name, sale_year, sale_month;


-- Query 2: Running Total and Top Products Per Category
-- Calculates a running total of sales for each product category and identifies the top 3
-- products within each category based on total sales.

WITH category_sales AS (
    -- Subquery to calculate the total sales per product.
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(p.price * s.quantity) AS total_sales
    FROM
        company_data.sales AS s
    JOIN
        company_data.products AS p ON s.product_id = p.product_id
    GROUP BY
        p.product_id, p.product_name, p.category
)
SELECT
    product_name,
    category,
    total_sales,

    -- Use SUM with an OVER clause to calculate a running total of sales within each category.
    SUM(total_sales) OVER (
        PARTITION BY category
        ORDER BY total_sales DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,

    -- Use RANK to assign a rank to each product based on its sales within its category.
    -- This allows us to easily filter for the top N products later.
    RANK() OVER (
        PARTITION BY category
        ORDER BY total_sales DESC
    ) AS category_rank
FROM
    category_sales
ORDER BY
    category, total_sales DESC;


-- Query 3: N-th Tile Pricing and Monthly Average Comparison
-- This query identifies the top 20% of products by price within each category (NTILE(5))
-- and compares the price of these top-tier products to the average product price
-- sold in the same month and region.

WITH ranked_products AS (
    -- Subquery to rank products by price within their category using NTILE.
    -- NTILE(5) divides the products into 5 groups (or tiles) of roughly equal size.
    -- NTILE 1 will contain the top 20% of products by price.
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        NTILE(5) OVER (
            PARTITION BY p.category
            ORDER BY p.price DESC
        ) AS price_tile
    FROM
        company_data.products AS p
),
monthly_averages AS (
    -- Subquery to calculate the average price of all products sold in a given month and region.
    SELECT
        EXTRACT(YEAR FROM s.sale_date) AS sale_year,
        EXTRACT(MONTH FROM s.sale_date) AS sale_month,
        s.region,
        AVG(p.price) AS average_monthly_price
    FROM
        company_data.sales AS s
    JOIN
        company_data.products AS p ON s.product_id = p.product_id
    GROUP BY
        sale_year, sale_month, s.region
)
SELECT
    rp.product_name,
    rp.category,
    rp.price,
    ma.sale_year,
    ma.sale_month,
    ma.region,
    ma.average_monthly_price,
    (rp.price - ma.average_monthly_price) AS price_difference
FROM
    company_data.sales AS s
JOIN
    ranked_products AS rp ON s.product_id = rp.product_id
JOIN
    monthly_averages AS ma ON
        EXTRACT(YEAR FROM s.sale_date) = ma.sale_year AND
        EXTRACT(MONTH FROM s.sale_date) = ma.sale_month AND
        s.region = ma.region
WHERE
    -- Filter to only include products in the top price tile (top 20%).
    rp.price_tile = 1
GROUP BY
    rp.product_name, rp.category, rp.price, ma.sale_year, ma.sale_month, ma.region, ma.average_monthly_price
ORDER BY
    rp.category, rp.price DESC;
