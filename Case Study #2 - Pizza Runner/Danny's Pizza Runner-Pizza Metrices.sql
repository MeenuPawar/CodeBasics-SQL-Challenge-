SElect * from runners;
SElect * from customer_orders1;
SElect * from runner_orders1;
SElect * from pizza_names;
SElect * from pizza_recipes;
SElect * from pizza_toppings;

drop table runner_orders;
SET SQL_SAFE_UPDATES=0;

# CLEANING DATA

-- Copying table to new table
create table customer_orders1 as 
(
select order_id,customer_id,pizza_id,exclusions,extras,order_time from customer_orders
);

-- Cleaning data
update customer_orders1 
set
exclusions = case exclusions when  'null' then null else exclusions end,
extras = case extras when  'null' then null else extras end;

select * from runner_orders1;

-- Copying table and cleaning data

drop table runner_orders1;

create table runner_orders1 as 
(
select order_id,runner_id,pickup_time,
case 
when distance like '%km' then trim('km' from distance) 
else distance 
end as distance,
case
when duration like '%mins' then  trim('mins' from duration)
when duration like '%minute' then  trim('minute' from duration)
when duration like '%minutes' then  trim('minutes' from duration)
else duration
end as duration,
cancellation
 from runner_orders
);

-- Cleaning data

update runner_orders1
set 
pickup_time = case pickup_time when 'null' then null else pickup_time end,
distance = case distance when 'null' then null else distance end,
duration = case duration when 'null' then null else duration end,
cancellation = case cancellation when 'null' then null else cancellation end;

update runner_orders1
set
cancellation = case cancellation when '' then null else cancellation end;

update customer_orders1
set
exclusions = case exclusions when '' then null else exclusions end,
extras = case extras when '' then null else extras end;

-- Update datatype in runner_orders1 table

alter table runner_orders1
modify column pickup_time datetime null,
modify column distance decimal(5,2) null,
modify column duration int null;

SElect * from runners;
SElect * from customer_orders1;
SElect * from runner_orders1;
SElect * from pizza_names;
SElect * from pizza_recipes;
SElect * from pizza_toppings;

 # 1.How many pizzas were ordered?
  select count(1) from customer_orders1;
 
 #2.How many unique customer orders were made?
 select count(distinct order_id) from customer_orders1;
 
 #3.How many successful orders were delivered by each runner?
 select runner_id,count(order_id) as orders_deliverd 
 from runner_orders1 
 where cancellation is null
 group by 1
 order by 1;
 
 # 4.How many of each type of pizza was delivered?
 select c.pizza_id,p.pizza_name,count(1) from 
 customer_orders1 c join
 runner_orders1 r 
 on c.order_id=r.order_id
 join pizza_names p on c.pizza_id=p.pizza_id
 where cancellation is null
 group by 1,2
 order by 1;
 
 # 5.How many Vegetarian and Meatlovers were ordered by each customer?
 
select c.customer_id,
count( case when pizza_id=1 then pizza_id end )as Meat_lovers_count,
count( case when pizza_id=2 then pizza_id end )as Vegetarian_count
from 
 customer_orders1 c 
 group by 1
 order by 1;
 
 # 6.What was the maximum number of pizzas delivered in a single order?
 
 with cte as 
 (
 select order_id,count(1) as No_of_pizza 
 from customer_orders1
 group by 1
 order by 1
 )
 
 select order_id,max(No_of_pizza) from cte
 group by 1
 order by 2 desc
 limit 1;
 
 # 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 
select customer_id,
sum(case when (exclusions is null and extras is null) then 1 else 0 end) as NO_change,
sum(case when ((exclusions is not null and exclusions !=0) or (extras is not null and extras !=0)) then 1 else 0 end) as AtleastOne_Change
from customer_orders1 c
join runner_orders1 r on c.order_id=r.order_id
where r.cancellation is null
group by 1
order by 1;

# 8.How many pizzas were delivered that had both exclusions and extras?

select customer_id,
sum(case when ((exclusions is not null and exclusions !=0) and (extras is not null and extras !=0)) then 1 else 0 end) as Had_both_exclusion_and_extras
from customer_orders1 c
join runner_orders1 r on c.order_id=r.order_id
where r.cancellation is null
group by 1
order by 2 desc;

# 9.What was the total volume of pizzas ordered for each hour of the day?

select hour(order_time) as hour,count(1) as Volume_ordered from customer_orders1
group by 1
order by 1;

# 10.What was the volume of orders for each day of the week?

select dayname(order_time) as Day,count(1) as Volume_ordered from customer_orders1
group by 1
order by 1;