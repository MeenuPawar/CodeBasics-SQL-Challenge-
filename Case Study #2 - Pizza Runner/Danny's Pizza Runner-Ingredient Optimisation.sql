use demo;
SElect * from runners;
SElect * from customer_orders1;
SElect * from runner_orders1;
SElect * from pizza_names;
SElect * from pizza_recipes1;
SElect * from pizza_toppings;
SElect * from pizza_recipes;

# 1.What are the standard ingredients for each pizza?

create table pizza_recipes1
(
pizza_id int,
toppings int);

insert into pizza_recipes1
(pizza_id, toppings) 
values
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);


select p1.pizza_id,p1.toppings from pizza_recipes1 p1 join pizza_recipes1 p2
on p1.pizza_id <> p2.pizza_id
where p1.toppings=p2.toppings;

with cte as
(
select pizza_id,topping_id,topping_name from pizza_recipes1 r
join pizza_toppings t on r.toppings=t.topping_id
)

select pizza_id,group_concat(topping_name) as standard_toppings from cte group by 1;

# 2.What was the most commonly added extra?

create table index_table1
(
index_col int primary key
);

INSERT INTO index_table1 VALUES
( 1 ), ( 2 ), ( 3 ), ( 4 ), ( 5 ), ( 6 ), ( 7 ), ( 8 ), ( 9 ), ( 10 ),( 11 ), ( 12 ), ( 13 ), ( 14 ); 

with cte as
(
select i.index_col,substring_index(substring_index(all_tags,',',index_col),',',-1) as one_tag
from
(
select group_concat(extras separator ',') as all_tags,
length(group_concat(extras separator ',')) - length(replace(group_concat(extras separator ','),',','')) + 1 as count_tags from customer_orders1
)c join index_table1 i 
where i.index_col<=c.count_tags
)


select one_tag as topping_id,pt.topping_name as topping,count(one_tag) as occurences
 from cte c join pizza_toppings pt on
c.one_tag=pt.topping_id
group by 1,2
order by 3 desc;

#Q3. What was the most common exclusion?

create table index_table1
(
index_col int primary key
);

INSERT INTO index_table1 VALUES
( 1 ), ( 2 ), ( 3 ), ( 4 ), ( 5 ), ( 6 ), ( 7 ), ( 8 ), ( 9 ), ( 10 ),( 11 ), ( 12 ), ( 13 ), ( 14 ); 

with cte as
(
select i.index_col,substring_index(substring_index(all_tags,',',index_col),',',-1) as one_tag
from
(
select group_concat(exclusions separator ',') as all_tags,
length(group_concat(exclusions separator ',')) - length(replace(group_concat(exclusions separator ','),',','')) + 1 as count_tags from customer_orders1
)c join index_table1 i 
where i.index_col<=c.count_tags
)


select one_tag as topping_id,pt.topping_name as topping,count(one_tag) as occurences
 from cte c join pizza_toppings pt on
c.one_tag=pt.topping_id
group by 1,2
order by 3 desc;

/*  Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lover,s - Exclude Beef,
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */

DROP TABLE IF EXISTS Extras_exclusions;
create temporary table Extras_exclusions as 
select * ,
substring_index(exclusions,',',1) as exclusions_1,
case when exclusions regexp ',' then substring_index(exclusions,',',-1) end as exclusions_2,
substring_index(extras,',',1) as extras_1,
case when extras regexp ',' then substring_index(extras,',',-1) end as extras_2
from customer_orders1;

select * from Extras_exclusions;

with t4 as
(
with t3 as
(
with t2 as
(
with t1 as
(
select order_id,customer_id,p.pizza_name as pizza_name,t.topping_name as exclusions_1,exclusions_2,extras_1,extras_2
from Extras_exclusions e
left join pizza_names p on e.pizza_id=p.pizza_id
left join pizza_toppings t on e.exclusions_1=t.topping_id
)
select order_id,customer_id,pizza_name,exclusions_1,t.topping_name as exclusions_2,extras_1,extras_2
from t1 
left join pizza_toppings t on t1.exclusions_2=t.topping_id
)
select order_id,customer_id,pizza_name,exclusions_1,exclusions_2,t.topping_name as extras_1,extras_2
from t2 
left join pizza_toppings t on t2.extras_1=t.topping_id
)
select order_id,customer_id,pizza_name,exclusions_1,exclusions_2,extras_1,t.topping_name as extras_2
from t3 
left join pizza_toppings t on t3.extras_2=t.topping_id
)

select *,
case	when coalesce(exclusions_1,exclusions_2,extras_1,extras_2) is null then pizza_name
		when coalesce(exclusions_2,extras_1,extras_2) is null and exclusions_1 is not null then concat(pizza_name,' ','Exclude-',exclusions_1)
        when coalesce(exclusions_2,exclusions_1,extras_2) is null and extras_1 is not null then concat(pizza_name,' ','Extra-',extras_1)
        when coalesce(exclusions_2,extras_2) is not null then concat_ws(" ",pizza_name ,'Exclude-',exclusions_1,',',exclusions_2,'Extra-',extras_1,',',extras_2)
        end as OrderDetails
from t4;

/* Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

drop table if exists item_records;
create temporary table item_records
with t3 as
(
with t2 as
(
with t1 as
(
select order_id,customer_id,p.pizza_name as pizza_name,t.topping_name as exclusions_1,exclusions_2,extras_1,extras_2
from Extras_exclusions e
left join pizza_names p on e.pizza_id=p.pizza_id
left join pizza_toppings t on e.exclusions_1=t.topping_id
)
select order_id,customer_id,pizza_name,exclusions_1,t.topping_name as exclusions_2,extras_1,extras_2
from t1 
left join pizza_toppings t on t1.exclusions_2=t.topping_id
)
select order_id,customer_id,pizza_name,exclusions_1,exclusions_2,t.topping_name as extras_1,extras_2
from t2 
left join pizza_toppings t on t2.extras_1=t.topping_id
)
select order_id,customer_id,pizza_name,exclusions_1,exclusions_2,extras_1,t.topping_name as extras_2
from t3 
left join pizza_toppings t on t3.extras_2=t.topping_id;

select * from item_records;

create temporary table toppings2
select pizza_name,group_concat(topping_name,' ') as ingredients
from pizza_recipes1 r 
join pizza_toppings t on r.toppings=t.topping_id
join pizza_names n on r.pizza_id = n.pizza_id
group by 1;

with cte as
(
select order_id,t.pizza_name as pizza_name,extras_1,extras_2,ingredients
from item_records t join toppings2 t1 on t.pizza_name=t1.pizza_name
)

select order_id,pizza_name,extras_1,extras_2,concat(pizza_name,' : ',
case
when locate(extras_1,ingredients)>0 and locate(extras_2,ingredients)>0 then replace(replace(ingredients,extras_1,concat('2x',extras_1)),extras_2,concat('2x',extras_2))
when locate(extras_1,ingredients)>0 then replace(ingredients,extras_1,concat('2x',extras_1))
when locate(extras_2,ingredients)>0 then replace(ingredients,extras_2,concat('2x',extras_2))
else ingredients
end) as ingredients
from cte
group by 1,2,3,4,5;

#6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

DROP TABLE IF EXISTS extras_exc;
CREATE TEMPORARY TABLE extras_exc 
 SELECT pizza_id as id, toppings as topping FROM pizza_recipes1;
INSERT INTO extras_exc SELECT pizza_id, extras_1 AS topping FROM extras_exclusions
 WHERE extras_1 IS NOT NULL;
INSERT INTO extras_exc SELECT pizza_id, extras_2 AS topping FROM extras_exclusions
 WHERE extras_2 IS NOT NULL;
 
select * from extras_exc;

SELECT t.topping_name, COUNT((p.toppings))
FROM extras_exc e
JOIN pizza_recipes1 p ON p.pizza_id = e.id
JOIN pizza_toppings t ON p.toppings = t.topping_id
GROUP BY t.topping_name
ORDER BY 2 DESC