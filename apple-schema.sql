
CREATE DATABASE IF NOT EXISTS apple;
USE apple;

-- Disable foreign key checks temporarily to safely refresh database tables
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS purchase_details;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS store;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS category;
SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- 1. TABLE CORE SCHEMA DEFINITIONS
-- =============================================================================

CREATE TABLE category (
    category_id INT NOT NULL,
    category_name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_category PRIMARY KEY (category_id)
);

CREATE TABLE customer (
    customer_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    CONSTRAINT pk_customer PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

CREATE TABLE store (
    store_id INT NOT NULL,
    store_name VARCHAR(100) NOT NULL,
    store_location VARCHAR(100) NOT NULL,
    CONSTRAINT pk_store PRIMARY KEY (store_id)
);

CREATE TABLE employee (
    employee_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    store_id INT NOT NULL,
    CONSTRAINT pk_employee PRIMARY KEY (employee_id),
    CONSTRAINT fk_employee_store FOREIGN KEY (store_id) REFERENCES store(store_id)
);

CREATE TABLE product (
    product_id INT NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL, -- Refactored to numeric for business analytics
    is_subscription INT NOT NULL DEFAULT 0, -- 1 flag handles monthly items like AppleCare cleanly
    category_id INT NOT NULL,
    CONSTRAINT pk_product PRIMARY KEY (product_id),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE purchase (
    purchase_id INT NOT NULL,
    purchase_date DATETIME NOT NULL,
    customer_id INT NOT NULL,
    store_id INT NOT NULL,
    employee_id INT NOT NULL,
    CONSTRAINT pk_purchase PRIMARY KEY (purchase_id),
    CONSTRAINT fk_purchase_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_purchase_store FOREIGN KEY (store_id) REFERENCES store(store_id),
    CONSTRAINT fk_purchase_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE purchase_details (
    purchase_details_id INT NOT NULL,
    serial_num VARCHAR(50) NOT NULL,
    line_item_amount DECIMAL(10, 2) NOT NULL, -- Refactored to numeric
    purchase_id INT NOT NULL,
    product_id INT NOT NULL,
    CONSTRAINT pk_purchase_details PRIMARY KEY (purchase_details_id),
    CONSTRAINT uq_serial_num UNIQUE (serial_num),
    CONSTRAINT fk_details_purchase FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id),
    CONSTRAINT fk_details_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);


-- =============================================================================
-- 2. DATA INGESTION ENGINE
-- =============================================================================

-- --- CATEGORIES ---
INSERT INTO category (category_id, category_name) VALUES
(1, 'iPhone'),
(2, 'Mac'),
(3, 'Service'),
(4, 'iPad'),
(5, 'Wearables');

-- --- CUSTOMERS ---
INSERT INTO customer (customer_id, first_name, last_name, email) VALUES
(1, 'Jordan', 'Miller', 'j.miller@icloud.com'),
(2, 'Kenny', 'Margo', 'kmarg12@icloud.com'),
(3, 'Billie', 'Holiday', 'bill.holl1@icloud.com'),
(4, 'Taylor', 'Swift', 't.swift@icloud.com'),
(5, 'Bruce', 'Wayne', 'bwayne@waynecorp.com'),
(6, 'Clark', 'Kent', 'ckent@dailyplanet.com'),
(7, 'Tony', 'Stark', 'tstark@starkindustries.com'),
(8, 'Selina', 'Kyle', 'skyle@gotham.org'),
(9, 'Diana', 'Prince', 'dprince@themyscira.gov');

-- --- STORES ---
INSERT INTO store (store_id, store_name, store_location) VALUES
(1, 'Apple 5th Ave', 'New York City, NY'),
(2, 'Grand Parkway Valley', 'Houston, TX'),
(3, '123 Parker St', 'Pawnee, IN'),
(4, 'Apple Union Square', 'San Francisco, CA'),
(5, 'Apple Millennium Park', 'Chicago, IL');

-- --- EMPLOYEES ---
INSERT INTO employee (employee_id, first_name, last_name, role, store_id) VALUES
(1, 'Alex', 'Smith', 'Store Manager', 1),
(2, 'Betty', 'White', 'Sales Associate', 1),
(3, 'Michael', 'Jordan', 'Customer Service Rep', 1),
(4, 'Billie', 'Jean', 'Sales Associate', 2),
(5, 'Kenny', 'Loggins', 'Store Manager', 2),
(6, 'Willie', 'Nelson', 'Customer Service Rep', 2),
(7, 'Ron', 'Swanson', 'Store Manager', 3),
(8, 'Leslie', 'Knope', 'Sales Associate', 3),
(9, 'Tom', 'Havenford', 'Customer Service Rep', 3),
(10, 'Peter', 'Parker', 'Store Manager', 4),
(11, 'Gwen', 'Stacy', 'Sales Associate', 4),
(12, 'Tony', 'Stark', 'Store Manager', 5),
(13, 'Natasha', 'Romanoff', 'Sales Associate', 5);

-- --- PRODUCTS ---
-- Note: Subscriptions are logged as baseline values, flagged by 'is_subscription'
INSERT INTO product (product_id, model_name, price, is_subscription, category_id) VALUES
(1, 'iPhone 17 Pro', 1099.00, 0, 1),
(2, 'iPhone 17 Pro Max', 1199.00, 0, 1),
(3, 'iPhone 17', 799.00, 0, 1),
(4, 'MacBook Neo', 599.00, 0, 2),
(5, 'MacBook Air', 1099.00, 0, 2),
(6, 'MacBook Pro', 1699.00, 0, 2),
(7, 'AppleCare+', 9.99, 1, 3),
(8, 'AppleCare One', 19.99, 1, 3),
(9, 'iPad Pro', 999.00, 0, 4),
(10, 'iPad Air', 599.00, 0, 4),
(11, 'Apple Watch Ultra', 799.00, 0, 5),
(12, 'AirPods Pro', 249.00, 0, 5),
(13, 'Mac Studio', 1999.00, 0, 2),
(14, 'Studio Display', 1599.00, 0, 2),
(15, 'Magic Keyboard', 199.00, 0, 5),
(16, 'Apple Pencil Pro', 129.00, 0, 5);

-- --- PURCHASES ---
INSERT INTO purchase (purchase_id, purchase_date, customer_id, store_id, employee_id) VALUES
(1, '2026-01-05 12:24:00', 2, 2, 2),
(2, '2026-01-06 01:30:00', 1, 2, 5),
(3, '2026-01-06 02:05:00', 3, 2, 7),
(4, '2026-01-08 02:35:00', 1, 3, 8),
(5, '2026-01-09 02:58:00', 3, 3, 9),
(6, '2026-01-10 03:07:00', 3, 3, 1),
(7, '2026-01-12 03:48:00', 2, 1, 3),
(8, '2026-01-18 04:25:00', 2, 1, 4),
(9, '2026-01-18 06:10:00', 1, 1, 6),
(10, '2026-01-20 10:15:00', 4, 4, 11),
(11, '2026-01-21 14:30:00', 5, 5, 13),
(12, '2026-01-22 16:45:00', 6, 4, 10),
(13, '2026-01-23 11:00:00', 1, 1, 2),
(14, '2026-01-24 09:15:00', 2, 5, 12),
(15, '2026-01-25 15:20:00', 3, 2, 4),
(16, '2026-02-01 10:00:00', 7, 1, 2), 
(17, '2026-02-02 11:14:00', 8, 4, 11),
(18, '2026-02-03 13:45:00', 9, 5, 13),
(19, '2026-02-14 18:22:00', 4, 1, 2), 
(20, '2026-02-15 12:05:00', 1, 3, 8);

-- --- PURCHASE DETAILS ---
INSERT INTO purchase_details (purchase_details_id, serial_num, line_item_amount, purchase_id, product_id) VALUES
(1, 'SN5K9M2L7Q4X', 799.00, 1, 3),
(2, 'SN8P3R6T1V9W', 1099.00, 2, 1),
(3, 'SN2J4H8K5N7C', 19.99, 3, 8),
(4, 'SN6B9F2D8G3E', 9.99, 4, 7),
(5, 'SN1W7Y5Z3A6S', 1099.00, 5, 5),
(6, 'SN4L8M2P9Q5R', 1199.00, 6, 2),
(7, 'SN7J6H4F2D9B', 599.00, 7, 4),
(8, 'SN2W9Y7Z4A8S', 1699.00, 8, 6),
(9, 'SN3M7X2D9K4L', 799.00, 9, 3),    
(10, 'SN9K2M4L7Q1X', 999.00, 10, 9),  
(11, 'SN4P8R3T2V1W', 799.00, 11, 11), 
(12, 'SN5J2H9K4N8C', 599.00, 12, 10), 
(13, 'SN1B7F3D9G2E', 1099.00, 13, 1), 
(14, 'SN8W2Y6Z4A3S', 249.00, 14, 12), 
(15, 'SN3L9M1P7Q4R', 1199.00, 15, 2), 
(16, 'SN9M2L7Q4X5K', 1999.00, 16, 13), 
(17, 'SN3R6T1V9W8P', 1599.00, 16, 14), 
(18, 'SN4H8K5N7C2J', 999.00, 17, 9),   
(19, 'SN9F2D8G3E6B', 129.00, 17, 16),  
(20, 'SN7Y5Z3A6S1W', 1699.00, 18, 6),  
(21, 'SN8M2P9Q5R4L', 249.00, 19, 12),  
(22, 'SN6H4F2D9B7J', 799.00, 20, 3);


-- =============================================================================
-- 3. SCHEMA INTEGRITY AUDIT (QA VERIFICATION)
-- =============================================================================
SELECT 'Category Table' AS Table_Name, COUNT(*) AS Total_Rows FROM category
UNION ALL
SELECT 'Customer Table', COUNT(*) FROM customer
UNION ALL
SELECT 'Store Table', COUNT(*) FROM store
UNION ALL
SELECT 'Employee Table', COUNT(*) FROM employee
UNION ALL
SELECT 'Product Table', COUNT(*) FROM product
UNION ALL
SELECT 'Purchase Table', COUNT(*) FROM purchase
UNION ALL
SELECT 'Purchase Details Table', COUNT(*) FROM purchase_details;