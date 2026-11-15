# Project Title - Apple Retail Sales Database

This project is a relational SQL database that models Apple’s retail sales operations. It stores information about products, product categories, customers, Apple stores, employees, purchases, and purchase details. The database can be used to analyze sales activity, product performance, store transactions, and customer purchases.

## Instructions for Build and Use

Steps to build and/or run the software:

1. Install and open a MySQL-compatible database system, such as MySQL Workbench.
2. Open the apple-schema.sql file.
3. Run the complete SQL script.

Instructions for using the software:

1. Select the database: USE apple;
2. Query the tables using SQL statements such as: SELECT * FROM product;
3. Join tables to analyze sales information: SELECT 
    p.model_name,
    c.category_name,
    pd.line_item_amount,
    pu.purchase_date
FROM purchase_details pd
JOIN product p ON pd.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
JOIN purchase pu ON pd.purchase_id = pu.purchase_id;
4. Use aggregate functions such as COUNT, SUM, and AVG to analyze product sales, store performance, and purchase totals.

## Development Environment

To recreate the development environment, you need the following software and/or libraries with the specified versions:

* MySQL Server 8.0 or a compatible MySQL database system
* MySQL Workbench or another SQL editor
* SQL support for tables, primary keys, foreign keys, joins, aggregate functions, and constraints
* A computer capable of running a local MySQL database server

## Useful Websites to Learn More

I found these websites useful in developing this software:

* [[W3Schools | SQL Tutorial](https://www.w3schools.com/sql/)]
* [[W3Schools | MySQL Tutorial](https://www.w3schools.com/mysql/default.asp)]

## Future Work

The following items I plan to fix, improve, and/or add to this project in the future:

* [ ] Add monthly and yearly sales analysis.
* [ ] Add discount, tax, payment method, and shipping information.
* [ ] Add inventory tracking for each store.
