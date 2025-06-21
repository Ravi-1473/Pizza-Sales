-- ## Pizza Sales Project

-- Project Setup & Creating Database:- 
Create database pizzahut;
use pizzahut;

-- Creating Table pizzas:-
Create table pizzas (
pizza_id varchar(20) primary key,	
pizza_type_id varchar(15) not null ,
size varchar(5) not null,	
price float not null
);


-- Creating table pizza_types:-
Create table pizza_types(
pizza_type_id varchar(15) primary key,
pizza_name varchar(50) not null,
category varchar(10) not null ,	
ingredients varchar(110) not null
);


-- Creating table orders:- 
Create table orders (
order_id int primary key,	
order_date date not null,	
order_time time not null
);


-- Creating table order_details:-
Create table order_details(
order_details_id int primary key,
order_id int not null,
pizza_id varchar(20) not null,
quantity int not null
);




-- Data Analysis
-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_order_placed
FROM
    orders;


-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.pizza_name AS pizza_name, pizzas.price AS price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size AS pizza_size,
    COUNT(order_details.order_details_id) AS total_count
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_size
ORDER BY total_count DESC;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.pizza_name AS pizza_name,
    SUM(order_details.quantity) AS net_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_name
ORDER BY net_quantity DESC
LIMIT 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category AS category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY total_quantity DESC;


-- 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS day_hours,
    COUNT(order_id) AS total_count
FROM
    orders
GROUP BY day_hours
ORDER BY 1;


-- 8. Join relevant tables to find the distribution of pizzas based on category and their pizza types.
SELECT 
    pizza_types.category AS pizza_category,
    pizza_types.pizza_name AS pizza_name,
    SUM(order_details.quantity) AS total_quantity
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY 1 , 2
ORDER BY 1;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_quantity_per_day), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date AS order_date,
            SUM(order_details.quantity) AS total_quantity_per_day
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quantity;


-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.pizza_name AS pizza_name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY 1
ORDER BY revenue DESC;


-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category AS category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                0) AS total_revenue
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS each_pizza_category_contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY each_pizza_category_contribution DESC;


-- 12. Analyze the cumulative revenue generated over time.
select order_date, revenue,
sum(revenue) over(order by order_date) as cum_revenue from 
(select orders.order_date as order_date, round(sum(pizzas.price*order_details.quantity),0) as revenue from  orders
join order_details 
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id =pizzas.pizza_id
group by order_date) as a ;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, p_name, revenue, rnk from 
(select category, p_name, revenue,
rank() over (partition by category order by revenue) as rnk from 
(select pizza_types.category as category, pizza_types.pizza_name as p_name, sum(order_details.quantity*pizzas.price) as revenue from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by category, p_name) as a) as b
where rnk <= 3;

