-- UPDATES ADDED

USE apple;


-- Week 6
SELECT first_name, last_name, email,
	SUBSTRING_INDEX(email, '@', -1) AS domain
FROM customer
WHERE SUBSTRING_INDEX(email, '@', -1) = 'icloud.com'
ORDER BY last_name, first_name;

-- Week 7
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, pu.purchase_id
FROM customer c
JOIN purchase pu ON c.customer_id = pu.customer_id
WHERE c.first_name LIKE 'Billie%';

-- Week 8
SELECT s.store_name, s.store_location, COUNT(pd.purchase_details_id) AS total_items_sold,
	SUM(CASE WHEN pd.line_item_amount LIKE '%/mo%' THEN 1 ELSE 0 END) AS subscription_items_count,
    SUM(CASE WHEN pd.line_item_amount NOT LIKE '%/mo%' THEN 1 ELSE 0 END) AS hardware_items_count
FROM purchase_details pd
INNER JOIN purchase p ON pd.purchase_id = p.purchase_id
INNER JOIN store s ON p.store_id = s.store_id
GROUP BY s.store_name, s.store_location;

-- Week 9
SELECT p.model_name, p.price, 
	COUNT(pd.purchase_details_id) AS total_units_sold
FROM product p
LEFT JOIN purchase_details pd ON p.product_id = pd.product_id
GROUP BY p.product_id, p.model_name, p.price
ORDER BY total_units_sold DESC;

-- Week 10
SELECT 
    c.category_name AS product_category,
    COUNT(pd.purchase_details_id) AS units_sold,
    SUM(pd.line_item_amount) AS category_revenue,
    ROUND(AVG(pd.line_item_amount), 2) AS average_unit_price
FROM category c
LEFT JOIN product pr ON c.category_id = pr.category_id
LEFT JOIN purchase_details pd ON pr.product_id = pd.product_id
GROUP BY c.category_name
ORDER BY category_revenue DESC;

-- Week 11
SELECT model_name, price 
FROM product 
WHERE price > (
	SELECT AVG(price) 
    FROM product
);

-- Week 12
WITH employee_revenue AS (
    SELECT s.store_name,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        SUM(pd.line_item_amount) AS total_revenue
    FROM purchase p
    JOIN purchase_details pd ON p.purchase_id = pd.purchase_id
    JOIN employee e ON p.employee_id = e.employee_id
    JOIN store s ON p.store_id = s.store_id
    GROUP BY s.store_name, e.employee_id, e.first_name, e.last_name
)
SELECT store_name, employee_name, total_revenue,
    RANK() OVER(PARTITION BY store_name ORDER BY total_revenue DESC) AS store_sales_rank
FROM employee_revenue;

-- CTE/VIEW

WITH CustomerSpendingCTE AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        COUNT(DISTINCT p.purchase_id) AS total_orders,
        SUM(pd.line_item_amount) AS total_amount_spent
    FROM customer c
    JOIN purchase p ON c.customer_id = p.customer_id
    JOIN purchase_details pd ON p.purchase_id = pd.purchase_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email
)
SELECT customer_id, customer_name, email, total_orders, total_amount_spent
FROM CustomerSpendingCTE
WHERE total_amount_spent > 1000.00
ORDER BY total_amount_spent DESC;

CREATE OR REPLACE VIEW employee_sales_performance AS
SELECT e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.role, s.store_name,
    COUNT(DISTINCT p.purchase_id) AS transactions_processed,
    IFNULL(SUM(pd.line_item_amount), 0.00) AS total_revenue_generated
FROM employee e
JOIN store s ON e.store_id = s.store_id
LEFT JOIN purchase p ON e.employee_id = p.employee_id
LEFT JOIN purchase_details pd ON p.purchase_id = pd.purchase_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.role, s.store_name;

SELECT 
    employee_name, role, store_name, transactions_processed, total_revenue_generated
FROM employee_sales_performance
WHERE transactions_processed > 0
ORDER BY total_revenue_generated DESC;

-- SUBQUERIES

SELECT first_name, last_name 
FROM customer 
WHERE customer_id IN (
	SELECT customer_id 
    FROM purchase 
    WHERE store_id = 1
);

-- WINDOW IMP 

-- 1
WITH employee_revenue AS (
    SELECT s.store_name,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        SUM(pd.line_item_amount) AS total_revenue
    FROM purchase p
    JOIN purchase_details pd ON p.purchase_id = pd.purchase_id
    JOIN employee e ON p.employee_id = e.employee_id
    JOIN store s ON p.store_id = s.store_id
    GROUP BY s.store_name, e.employee_id, e.first_name, e.last_name
)
SELECT store_name, employee_name, total_revenue,
    RANK() OVER(PARTITION BY store_name ORDER BY total_revenue DESC) AS store_sales_rank
FROM employee_revenue;

-- 2
SELECT p.purchase_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    prod.model_name, pd.line_item_amount AS item_cost,
    SUM(pd.line_item_amount) OVER (PARTITION BY p.customer_id ORDER BY p.purchase_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS lifetime_running_total
FROM purchase p
JOIN purchase_details pd ON p.purchase_id = pd.purchase_id
JOIN product prod ON pd.product_id = prod.product_id
JOIN customer c ON p.customer_id = c.customer_id
ORDER BY customer_name, p.purchase_date;

-- TRANSACTIONS

-- 1
START TRANSACTION;

INSERT INTO purchase (purchase_id, purchase_date, customer_id, store_id, employee_id) 
VALUES (21, '2026-07-16 14:30:00', 7, 1, 2);

INSERT INTO purchase_details (purchase_details_id, serial_num, line_item_amount, purchase_id, product_id) 
VALUES (23, 'SN-TONY-IPHONE17PM', 1199.00, 21, 2);

INSERT INTO purchase_details (purchase_details_id, serial_num, line_item_amount, purchase_id, product_id) 
VALUES (24, 'SN-TONY-APPLECARE', 9.99, 21, 7);

COMMIT;

-- 2
START TRANSACTION;

DELETE FROM purchase_details 
WHERE purchase_id = 20 
  AND serial_num = 'SN6H4F2D9B7J';

DELETE FROM purchase 
WHERE purchase_id = 20;

COMMIT;

SELECT * FROM purchase_details WHERE purchase_id = 21;

