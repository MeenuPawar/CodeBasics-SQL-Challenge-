use demo;
SElect * from runners;
SElect * from customer_orders1;
SElect * from runner_orders1;
SElect * from pizza_names;
SElect * from pizza_recipes;
SElect * from pizza_toppings;


# 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select week(registration_date),count(1) from runners 
group by 1;

# 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id,round(avg(TIMESTAMPDIFF(minute,order_time,pickup_time)),2)
from runner_orders1 r join customer_orders1 c 
on r.order_id=c.order_id
group by 1;

# 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?

with cte as
(select c.order_id,count(pizza_id) as pizza_count,TIMESTAMPDIFF(minute,order_time,pickup_time) as time_taken
from runner_orders1 r join customer_orders1 c 
on r.order_id=c.order_id
where distance!=0
group by 1,3
)
select pizza_count,avg(time_taken) from cte group by 1;

# 4.What was the average distance travelled for each customer?

select customer_id,avg(distance)
from runner_orders1 r join customer_orders1 c 
on r.order_id=c.order_id
where distance!=0
group by 1;

#5.What was the difference between the longest and shortest delivery times for all orders?

with cte as
(
select c.order_id,TIMESTAMPDIFF(minute,order_time,pickup_time) + duration as time_taken
from runner_orders1 r join customer_orders1 c 
on r.order_id=c.order_id
where distance!=0
)

select max(time_taken)-min(time_taken) as difference from cte;

# 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

with cte as 
(
select order_id,runner_id,sum(distance) as total_distance, sum(duration/60) as total_duration from runner_orders1 
where distance !=0
group by 1,2
)

select order_id,runner_id,round((total_distance/total_duration),2) as speed from cte order by 2;

# 7.What is the successful delivery percentage for each runner?

with total_orders as 
(
select runner_id,count(order_id) as total_orders
from runner_orders1 
group by 1
),orders_delivered as
(
select runner_id,count(order_id) as orders_delivered
from runner_orders1 
where cancellation is null
group by 1
)

select t.runner_id,(orders_delivered/total_orders) * 100 as Delivery_percentage
from total_orders t join orders_delivered o on t.runner_id = o.runner_id
group by 1;


