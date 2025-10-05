select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- Task 1: Retrieve the total number of orders placed.

select count(distinct order_id) from orders;
select count(distinct order_id) from order_details;

-- Task 2: Calculate the total revenue generated from pizza sales.
-- Revenue --> price * quantity

select * from pizzas;
select * from order_details;

select round(sum(price * quantity),2) as rev
from pizzas as p
inner join order_details as od on od.pizza_id = p.pizza_id;


-- Task 3: Identify the highest-priced pizza.

select * from pizzas;
select * from pizza_types;


select p.*, pt.name
from pizzas as p
left join pizza_types as pt on pt.pizza_type_id = p.pizza_type_id
order by price desc
limit 1;


-- Task 4: Identify the most common pizza size ordered.

select * from pizzas;
select * from order_details;

select p.size, count(distinct od.order_id) as orders, sum(od.quantity) as total_quantity
from order_details as od
inner join pizzas as p on p.pizza_id = od.pizza_id
group by p.size;


-- SALES

-- Task 1: List the top 5 most ordered pizza types along with their quantities.
select * from pizza_types;
select * from order_details;
select * from pizzas;

select pt.name, sum(od.quantity) as total_quantity
from pizza_types as pt 
left join pizzas as p on p.pizza_type_id = pt.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.name
order by total_quantity desc
limit 5;


-- Task 2: Determine the distribution of orders by hour of the day.

select * from orders;

select *
, sum(hourly_orders) over () as total_orders
, hourly_orders *100.00/ sum(hourly_orders) over () as contri_orders
from (
select hour(time) as hr, count(distinct order_id) as hourly_orders
from orders
group by hour(time)
) as a;


-- Task 3: Determine the top 3 most ordered pizza types based on revenue.
-- price * quantity

select * from pizzas;
select * from order_details;
select * from pizza_types;

select pt.name, sum(p.price * od.quantity) as rev
from pizza_types as pt
left join pizzas as p on p.pizza_type_id = pt.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.name
order by rev desc
limit 3;


-- Operational Insights
-- Task 1: Calculate the percentage contribution of each pizza type to total revenue.

with pizza_type_rev as (
select pt.name, sum(p.price * od.quantity) as rev
from pizza_types as pt
left join pizzas as p on p.pizza_type_id = pt.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.name
)

select *
, sum(rev) over () as total_rev
, round(rev *100.00/ sum(rev) over (), 2) as contribution
from pizza_type_rev;


-- Task 2: Analyze the cumulative revenue generated over time.
-- Price * quantity

select * from orders;
select * from order_details;
select * from pizzas;

with final as (
select o.date, round(sum(p.price * od.quantity),2) as rev
from orders as o
left join order_details as od on od.order_id = o.order_id
left join pizzas as p on p.pizza_id = od.pizza_id
group by o.date
)

select *
, round(sum(rev) over (order by date rows between unbounded preceding and current row), 0) as cumm_total
from final;

-- Task 3: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- price * quantity

select * from pizzas;
select * from order_details;
select * from pizza_types;

select * from (
select * 
, dense_rank() over (partition by category order by rev desc) as rn
from (
select pt.category, pt.name, round(sum(od.quantity * p.price), 2) as rev
from pizza_types as pt
left join pizzas as p on p.pizza_type_id = pt.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.category, pt.name
) as a
) as a1
where rn <= 3;


-- Category-Wise Analysis
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select * from order_details;
select * from pizza_types;
select * from pizzas;

select pt.category, sum(od.quantity) as cat_quantity
from pizza_types as pt
left join pizzas as p on p.pizza_type_id = pt.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.category;


-- Task 2: Join relevant tables to find the category-wise distribution of pizzas.
with final as (
select pt.category, sum(od.quantity) as cat_quantity
from pizza_types as pt
left join pizzas as p on p.pizza_type_id = pt.pizza_type_id
left join order_details as od on od.pizza_id = p.pizza_id
group by pt.category
)

select *
, cat_quantity *100.00/ sum(cat_quantity) over () as distribution
from final;


-- Task 3: Group the orders by the date and calculate the average number of pizzas ordered per day.

select avg(total_quantity)
from (
select date, sum(od.quantity) as total_quantity
from orders as o
left join order_details as od on od.order_id = o.order_id
group by date
) as a;