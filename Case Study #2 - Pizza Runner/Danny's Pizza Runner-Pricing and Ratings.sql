use demo;
SElect * from runners;
SElect * from customer_orders1;
SElect * from runner_orders1;
SElect * from pizza_names;
SElect * from pizza_recipes1;
SElect * from pizza_toppings;
SElect * from pizza_recipes;

/* 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees? */

with cte as
(
select runner_id,pizza_id,count(pizza_id) as pizza_count
from customer_orders1 c join runner_orders1 r on c.order_id=r.order_id
where r.cancellation is null
group by 1,2
),pizza_cost as
(
select *,
case
	when runner_id=1 and pizza_id=1 then pizza_count*12
    when runner_id=1 and pizza_id=2 then pizza_count*10	
    when runner_id=2 and pizza_id=1 then pizza_count*12
    when runner_id=2 and pizza_id=2 then pizza_count*10
	when runner_id=3 and pizza_id=1 then pizza_count*12
    when runner_id=3 and pizza_id=2 then pizza_count*10
    end as pizza_cost
from cte
)

select runner_id,sum(pizza_cost) from pizza_cost group by 1;

SELECT 
 SUM(CASE WHEN pizza_id=1 THEN 12
    WHEN pizza_id = 2 THEN 10
    END) AS Total_earnings
 FROM runner_orders1 r
JOIN customer_orders1 c ON c.order_id = r.order_id
WHERE r.cancellation IS  NULL;

/* 2.What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra*/

WITH cte AS
(SELECT 
 (CASE WHEN pizza_id=1 THEN 12
    WHEN pizza_id = 2 THEN 10
    END) AS pizza_cost, 
    c.exclusions,
    c.extras
 FROM runner_orders1 r
JOIN customer_orders1 c ON c.order_id = r.order_id
WHERE r.cancellation IS  NULL
)

SELECT 
 SUM(CASE WHEN extras IS NULL THEN pizza_cost
  WHEN LENGTH(extras) = 1 THEN pizza_cost + 1
        ELSE pizza_cost + 2
        END )
FROM cte;

set @basecost = 138;
select (LENGTH(group_concat(extras)) - LENGTH(REPLACE(group_concat(extras), ',', '')) + 1) + @basecost as Total
from customer_orders1
inner join runner_orders1
on customer_orders1.order_id = runner_orders1.order_id
where extras is not null and extras !=0 and distance is not null;

/* The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - generate a schema for this new table and
insert your own data for ratings for each successful customer order between 1 to 5. */

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings 
 (order_id INTEGER,
    rating INTEGER);
INSERT INTO ratings
 (order_id ,rating)
VALUES 
(1,3),
(2,4),
(3,5),
(4,2),
(5,1),
(6,3),
(7,4),
(8,1),
(9,3),
(10,5);

/* 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas*/

select customer_id,c.order_id,runner_id,rating,order_time,pickup_time,timestampdiff(minute,order_time,pickup_time) as Time_between_order_and_pickup,duration as delivery_duration,
round((distance/(duration/60)),2) as Average_speed,count(c.pizza_id) as pizza_count
from customer_orders1 c 
left join ratings r on c.order_id=r.order_id
left join runner_orders1 ro on c.order_id=ro.order_id
group by 1,2,3,4,5,6,7,8,9;

/* 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
- how much money does Pizza Runner have left over after these deliveries? */

with cte as 
(
SELECT customer_id,c.order_id,runner_id,order_time,distance,duration,
 SUM(CASE WHEN pizza_id=1 THEN 12
    WHEN pizza_id = 2 THEN 10
    END) AS Total_earnings
 FROM runner_orders1 r
JOIN customer_orders1 c ON c.order_id = r.order_id
WHERE r.cancellation IS  NULL
group by 1,2,3,4,6,5
)

select sum(total_earnings)-sum(distance)*.30 as final_amount from cte;

