
# Pizza Sales SQL Project

## Project Overview

**Project Title**: Pizza Sales Analysis  
**Level**: Intermediate  
**Database**: `pizzahut`

This project demonstrates SQL skills applied to sales data from a pizza business. It includes setting up the database schema, inserting sample records, and running queries to answer business questions related to revenue, customer behavior, and product popularity. This project is ideal for aspiring data analysts and developers working with sales datasets.

## Objectives

1. **Set up a pizza sales database**: Create and populate a pizza sales database using structured schema and CSV files.
2. **Data Exploration**: Use SQL queries to explore total orders, revenues, and pizza trends.
3. **Business Analysis**: Gain insights into top-selling products, pizza sizes, and time-based trends.
4. **Advanced Reporting**: Perform in-depth revenue analysis and category-level breakdowns.

## Project Structure

### 1. Database Setup

- **Database Creation**: Create a new database named `pizzahut`.
- **Table Creation**: Four tables are created — `pizzas`, `pizza_types`, `orders`, and `order_details`.

```sql
CREATE DATABASE pizzahut;

CREATE TABLE pizzas (
    pizza_id VARCHAR(20) PRIMARY KEY,
    pizza_type_id VARCHAR(15) NOT NULL,
    size VARCHAR(5) NOT NULL,
    price FLOAT NOT NULL
);

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(15) PRIMARY KEY,
    pizza_name VARCHAR(50) NOT NULL,
    category VARCHAR(10) NOT NULL,
    ingredients VARCHAR(110) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL
);
```

### 2. Data Exploration

- **Total Orders**: Count how many total orders are in the dataset.
- **Revenue Generation**: Calculate revenue based on pizza prices and quantities sold.
- **Pizza Sizes**: Find the most commonly ordered pizza size.
- **Top Sellers**: Identify top-ordered pizza types and revenue earners.

```sql
SELECT COUNT(order_id) AS total_orders FROM orders;

SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

SELECT p.size, COUNT(od.order_details_id) AS total_count
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size ORDER BY total_count DESC;

SELECT pt.pizza_name, SUM(od.quantity) AS quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_name
ORDER BY quantity DESC
LIMIT 5;
```

### 3. Business Analysis

- **Category Insights**: Total quantity sold per category.
- **Hourly Trends**: Determine which hours have the most orders.
- **Revenue by Pizza Type**: Get top 3 pizzas per category based on revenue.

```sql
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

SELECT HOUR(order_time) AS hour, COUNT(*) AS total_orders
FROM orders GROUP BY hour ORDER BY hour;

SELECT pt.pizza_name, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_name
ORDER BY revenue DESC
LIMIT 3;
```

### 4. Advanced Queries

- **Revenue Contribution by Category**:
```sql
SELECT pt.category,
ROUND(SUM(od.quantity * p.price) / (SELECT SUM(od.quantity * p.price)
                                     FROM order_details od
                                     JOIN pizzas p ON od.pizza_id = p.pizza_id) * 100, 2) AS contribution
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;
```

- **Cumulative Revenue Over Time**:
```sql
SELECT order_date, revenue,
       SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT o.order_date, ROUND(SUM(od.quantity * p.price), 2) AS revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY o.order_date
) AS daily_revenue;
```

- **Top 3 Revenue Pizzas per Category**:
```sql
SELECT category, pizza_name, revenue FROM (
  SELECT pt.category, pt.pizza_name,
         ROUND(SUM(od.quantity * p.price), 2) AS revenue,
         RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rnk
  FROM pizza_types pt
  JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
  JOIN order_details od ON p.pizza_id = od.pizza_id
  GROUP BY pt.category, pt.pizza_name
) ranked WHERE rnk <= 3;
```

## Findings

- **Top-Selling Sizes**: Medium and large pizzas dominate in terms of volume.
- **High Revenue Pizzas**: Premium toppings and larger sizes generate the most income.
- **Order Time Trends**: Most orders come during afternoon and evening shifts.
- **Category Performance**: Each pizza category contributes differently to overall revenue.

## Reports

- **Sales Summary**: Total revenue, quantity by category, and most ordered pizzas.
- **Time Trends**: Insights on order frequency by hour and day.
- **Top Performers**: Pizzas that lead in revenue and volume.

## Conclusion

This project demonstrates how SQL can be applied to analyze transactional sales data from a pizza business. It includes data modeling, aggregation, window functions, and pattern discovery, all useful for real-world analytics and reporting.

## How to Use

1. **Download Data & Scripts**: Use the provided CSV files and schema.
2. **Set Up the Database**: Create the tables in a MySQL database and import the data.
3. **Run the Queries**: Execute the provided SQL queries to analyze the data.
4. **Modify for Practice**: Tweak or expand the queries to answer new questions.

## Author - Ravi Kumar

This project is part of my SQL learning and portfolio. I welcome feedback, collaboration, or opportunities to grow in data analytics and BI roles.
