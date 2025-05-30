CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

INSERT INTO sales (customer_id, order_date, product_id) VALUES
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

CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(50),
  price INT
);

INSERT INTO menu (product_id, product_name, price) VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members (customer_id, join_date) VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id,sum(price) as Total_Amount_spent
FROM menu as m
join sales as s
on m.product_id=s.product_id
group by customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,count(distinct(order_date)) Total_visits
FROM sales 
group by Customer_id;

-- 3. What was the first item from the menu purchased by each customer?
with cte as (
SELECT m.product_name,s.customer_id,s.order_date,rank()over(partition by customer_id order by order_date asc) as rn
FROM menu as m
join sales as s
on m.product_id=s.product_id
)
select order_date,customer_id,product_name
from cte 
where rn=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT Customer_id,product_name ,count(*) as total_purchases
FROM menu as m
join sales as s
on m.product_id=s.product_id
group by product_name,customer_id
order by total_purchases  desc;

-- 5. Which item was the most popular for each customer?
use dannys_diner;
with cte as (SELECT customer_id,m.product_name,m.product_id,count(order_date) as times_ordered
FROM sales as s
join menu as m 
on m.product_id=s.product_id
group by customer_id,m.product_id,m.product_name)
,ranked_cte as (
select customer_id,product_name,times_ordered,rank()over(partition by customer_id order by times_ordered desc) as rnk
from cte )
select customer_id,product_name,times_ordered,rnk
from ranked_cte
where rnk=1;

-- 6. Which item was purchased first by the customer after they became a member?

with cte as (
SELECT m.customer_id,join_date,me.product_name,order_date
FROM sales as s
join members as m
on s.customer_id=m.customer_id
join menu as me
on s.product_id=me.product_id
where order_date>= join_date 
),
ranked_cte as (
SELECT customer_id,join_date,product_name,order_date,rank()over(partition by customer_id order by order_date asc) as rnk
FROM cte)
select *
from ranked_cte 
where rnk=1;

-- 7. Which item was purchased just before the customer became a member?
with cte as (
SELECT m.customer_id,join_date,me.product_name,order_date
FROM sales as s
join members as m
on s.customer_id=m.customer_id
join menu as me
on s.product_id=me.product_id
where order_date<= join_date 
),
ranked_cte as (
SELECT customer_id,join_date,product_name,order_date,rank()over(partition by customer_id order by order_date desc) as rnk
FROM cte)
select *
from ranked_cte 
where rnk=1;
-- 8. What is the total items and amount spent for each member before they became a member?
with cte as 
(SELECT m.customer_id,join_date ,order_date ,me.product_id,me.product_name,price
FROM members as m
join sales as s
on m.customer_id=s.customer_id
join menu as me
on s.product_id=me.product_id
where order_date<join_date
)
,aggregated as
(
select count(*) as Total_items_ordered,sum(price) as Amount_spent_by_customer,customer_id
from cte 
group by customer_id
)
select * from aggregated;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select m.customer_id,
sum(
case when product_name='sushi' then price*20
else price*10
end) as total_points
FROM members as m
join sales as s
on m.customer_id=s.customer_id
join menu as me
on s.product_id=me.product_id
group by m.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?

select m.customer_id,
sum(
case when s.order_date between m.join_date and date_add(m.join_date ,interval 6 day)then price*20
else price*10
end) as total_points
FROM members as m
join sales as s
on m.customer_id=s.customer_id
join menu as me
on s.product_id=me.product_id
where order_date<='2021-01-31'
and m.customer_id in ('A','B')
group by m.customer_id;






