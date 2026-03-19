create table customers(
  customer_id int primary key ,
  customer_name varchar(50),
  city varchar(50),
  signup_date date
);


create table restaurants(
  restaurant_id int primary key ,
  restaurant_name varchar(50),
  cuisine_type varchar(50),
  city varchar(50),
  rating smallint
);

create table orders(
  order_id int primary key,
  customer_id int,
  restaurant_id int,
  order_date date ,
  total_amount decimal(10,2),
  foreign key (customer_id) references customers(customer_id),
  foreign key (restaurant_id) references restaurants(restaurant_id)
);

create table order_item(
  order_item_id int primary key,
  order_id int,
  food_item varchar(100),
  quantity int,
  price decimal(10,2),
  foreign key (order_id) references orders(order_id)
);

create table delivery(
  delivery_id int primary key,
  order_id int ,
  delivery_time int,
  delivery_status varchar(20),
  foreign key(order_id) references orders(order_id)
);


select count (*) as total_customer
from customers;

select count(*) as total_order
from orders;

select avg(total_amount) as average_order_amount
from orders;

select c.city ,count(o.order_id) as total_orders
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.city
order by total_orders desc;

select sum(total_amount) as total_revenue
from orders;

select  r.restaurant_name ,sum(o.total_amount) as top_restaurant_revenue
from  restaurants r
join orders o
on r.restaurant_id=o.restaurant_id
group by  r.restaurant_name
order by top_restaurant_revenue desc
limit 5 ;


select r.cuisine_type,count(o.order_id) as maximum_order_cusine_type
from restaurants r
join orders o 
on r.restaurant_id=o.restaurant_id
group by r.cuisine_type
order by maximum_order_cusine_type desc


select rating,restaurant_name
from restaurants
where rating =(select max(rating)
               from restaurants
);

select r.restaurant_name,sum (o.total_amount) as restaurants_revenue
from restaurants r
join orders o
on r.restaurant_id=o.restaurant_id
group by r.restaurant_name
order by restaurants_revenue desc ;


select c.customer_name, count(o.order_id) as top_customers
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_name 
order by top_customers desc 
limit 10;


select c.customer_name , count(o.order_id) as max_order
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_name
having count(o.order_id) >=2
order by max_order desc


select city, count(customer_id) as total_customer
from customers 
group by city
order by total_customer desc


select c.city,sum(o.total_amount)  as spend_max
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.city
order by spend_max desc ;


select 
        extract (month from order_date) as month ,
        sum(total_amount) as total_revenue
from orders
group by extract (month from order_date)
order by month desc
     
select food_item,count(order_item_id) as max_order_food
from order_item
group by food_item
order by max_order_food desc;

select avg(total_item)
from(
select order_id,sum(quantity) as total_item
from order_item
group by order_id
order by total_item  desc)



select avg(delivery_time) as avg_delivery_time
from delivery


SELECT 
  SUM(CASE WHEN delivery_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0
  / COUNT(*) AS cancelled_order_percentage
FROM delivery;

select 
    order_id,delivery_time
    from delivery
    where delivery_time = (
      select max(delivery_time) from delivery
    );
                

select 
    order_id,delivery_time
    from delivery
    where delivery_time = (
      select min(delivery_time) from delivery
    );

SELECT restaurant_name, food_item, total_quantity
FROM (
    SELECT 
        r.restaurant_name,
        oi.food_item,
        SUM(oi.quantity) AS total_quantity,
        RANK() OVER (
            PARTITION BY r.restaurant_id 
            ORDER BY SUM(oi.quantity) DESC
        ) AS rnk
    FROM restaurants r
    JOIN orders o 
        ON r.restaurant_id = o.restaurant_id
    JOIN order_item oi 
        ON o.order_id = oi.order_id
    GROUP BY r.restaurant_id, r.restaurant_name, oi.food_item
) 
WHERE rnk = 1;



SELECT city, restaurant_name, total_revenue
FROM (
    SELECT 
        r.city,
        r.restaurant_name,
        SUM(o.total_amount) AS total_revenue,
        RANK() OVER (
            PARTITION BY r.city 
            ORDER BY SUM(o.total_amount) DESC
        ) AS rnk
    FROM restaurants r
    JOIN orders o 
        ON r.restaurant_id = o.restaurant_id
    GROUP BY r.city, r.restaurant_name
) 
WHERE rnk = 1;



SELECT month, customer_name, total_spent
FROM (
    SELECT 
        EXTRACT(MONTH FROM o.order_date) AS month,
        c.customer_name,
        SUM(o.total_amount) AS total_spent,
        RANK() OVER (
            PARTITION BY EXTRACT(MONTH FROM o.order_date)
            ORDER BY SUM(o.total_amount) DESC
        ) AS rnk
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    GROUP BY month, c.customer_name
) t
WHERE rnk = 1;





SELECT 
    order_date,
    SUM(total_amount) AS daily_revenue,
    SUM(SUM(total_amount)) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM orders
GROUP BY order_date
ORDER BY order_date;





SELECT 
    r.cuisine_type,
    SUM(o.total_amount) AS total_revenue
FROM restaurants r
JOIN orders o 
    ON r.restaurant_id = o.restaurant_id
GROUP BY r.cuisine_type
ORDER BY total_revenue DESC;