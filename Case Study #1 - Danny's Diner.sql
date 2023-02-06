CREATE TABLE menu2 (
    product_id INTEGER,
    product_name VARCHAR(5),
    price INTEGER
);

INSERT INTO menu2 VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

CREATE TABLE members2(
  customer_id VARCHAR(5),
  join_date DATE
);

INSERT INTO members2 VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  Select * from sales2;
  
  drop table sales2;
  
  CREATE TABLE sales2 (
  customer_id VARCHAR(5),
  order_date DATE,
  product_id INTEGER);

INSERT INTO sales2 VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
  
create table master_table as select s.customer_id,s.product_id,s.order_date,m.join_date,mn.product_name,mn.price from sales2 s 
left outer join members2 m on s.customer_id=m.customer_id
left outer join  menu2 mn on s.product_id=mn.product_id;

  Select * from master_table;


 /* 1) What is the total amount each customer spent at the restaurant? */
 
 select customer_id,sum(price) from master_table 
 group by 1
 order by 2 desc;

#  2.How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as days_visited from master_table
group by 1
order by 2 desc;

# 3.What was the first item from the menu purchased by each customer?

select customer_id,product_name from master_table 
where order_date=(select min(order_date) from master_table)
group by 1,2;

# 4.What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name,count(product_name) as cnt from master_table 
group by 1
order by 2 desc
limit 1;

# 5.Which item was the most popular for each customer?

with cnt as
(
select customer_id,product_name,count(product_name) as cnt from master_table 
group by 1,2
), most_popular as
(
select *,dense_rank() over(partition by customer_id order by cnt desc) as rnk from cnt
)

select customer_id,product_name,cnt from most_popular where rnk=1;

# 6.Which item was purchased first by the customer after they became a member?

with cte as 
(
select customer_id,product_name,order_date,join_date,dense_rank() over(partition by customer_id order by order_date) as rnk from master_table 
where order_date >= join_date
group by 1,2,3,4
order by 3
)

select customer_id,product_name,order_date,join_date from cte where rnk=1;

# 7. Which item was purchased just before the customer became a member?

with cte as 
(
select customer_id,product_name,order_date,join_date,dense_rank() over(partition by customer_id order by order_date desc) as rnk from master_table 
where order_date < join_date 
group by 1,2,3,4
order by 3
)

select customer_id,product_name,order_date,join_date from cte where rnk=1;

# 8. What is the total items and amount spent for each member before they became a member?

select customer_id,count(product_name) as total_items,sum(price) as Total_amount from master_table 
where order_date < join_date 
group by 1
order by 3 desc;

#9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id,
sum(case when product_name='sushi' then 20*price else 10* price end ) as points
from master_table 
group by 1
order by 1;

#10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
# - how many points do customer A and B have at the end of January?

select customer_id,
sum(case when order_date <= (join_date+7) then 20*price else price end ) as points
from master_table 
where order_date >= join_date AND extract( month from order_date)=01
group by 1
order by 1;

select customer_id,order_date,join_date,product_name,price
from master_table 
where order_date >= join_date;

#Bonus Questions-Recreate the table

select customer_id,order_date,product_name,price,
case when join_date<=order_date then 'Y' else 'N' end as member
from master_table;

#2. Rank Members — fill non-members with null

with cte as 
(
select customer_id,order_date,product_name,price,
case when join_date<=order_date then 'Y' else 'N' end as member from master_table
)

select * ,
case when member='N' then null else dense_rank() over(partition by customer_id,member order by order_date) end as ranking
from cte;


/* 
Insights
1. Customer A and B visits more and spend more money in the Diner.
2. Ramen is the best selling product of all menu in diner.
3. Customers A and B are the most trusted customer.Danny might make some discounts or give bigger servings for these customers.
4. Customer B likes all the items in the Menu equally whereas Customer A & C likes the Ramen most.
5. Customers A and B ordered Sushi first before they became the members.
6. Customer B has ordered the maximum items and has paid maximum amount in the Diner
7. Points system might attract customers, even new ones. Say, earning 1500 points in a month provides special discounts, gifts etc. This would lead customers to become members.
*/