use Pizza_Sales_DB
select* from order_details_pizza
select* from orders_pizza
select* from pizza_types
select* from pizzas

--Q1: The total number of order place
select COUNT(order_details_id) as orders_placed from order_details_pizza


--Q2:The total revenue generated from pizza sales

--Here first we need to join the order_details_pizza and the pizzas tables based on the pizza_id as the order_details_pizza include
--the quantity of the pizzas sold and the pizzas table include the respective prices for each pizzas.

select order_details_id,order_id, a.pizza_id,size,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id
--After joining, we now need to add another column that helps find the revenue generated from each pizza_id wiz = quantity*price, So

select pizza_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c

--Finally, the revenue column can be summed to generate total revenue generated (a,b,c,d are sub-queries)
select sum(revenue) as Total_Revenue from
(select pizza_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d

--Q3: The highest priced pizza.

select*, ROW_NUMBER() over(order by price desc) as Top_price from pizzas
--Aliter
select top 1* from 
(select*, ROW_NUMBER() over(order by price desc) as Top_price from pizzas
)a order by price desc

--Q4: The most common pizza size ordered.

--here we first join the the order_detail_pizza and the pizzas table to obtain the different sizes of pizzas corressponding to the pizza_id
select pizza_id,c.quantity,size, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id

--From this we'll select and count he size of different pizzas grouped by size
select size, COUNT(size) as most_ordered_pizza_size from
(select pizza_id,c.quantity,size, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)e group by size order by most_ordered_pizza_size desc

-- Q5: The top 5 most ordered pizza types along their quantities.

--To determine the most ordered pizza types, we first need to join the order_details_pizza table with the pizzas table coz the pizzas table
--include the list of pizza_type_id which basically is the type of pizzas.
select pizza_id,c.quantity, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id

--then upon joining we'll select the pizza type id and determine the total pizza ordered and the quantities by counting the pizza_type_id
--as tot_pizza_ordered and summing the quantity as quantities. This will give us a list with pizza types alon with their tot ordered pizzas 
--and quantities.
select pizza_type_id, COUNT(pizza_type_id) as tot_pizz_ordered, SUM(quantity) as Quantities from
(select pizza_id,c.quantity, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)e group by pizza_type_id order by tot_pizz_ordered desc

--Finally from the list we'll select the top 5 
select Top 5* from
(select pizza_type_id, COUNT(pizza_type_id) as tot_pizz_ordered, SUM(quantity) as Quantities from(select pizza_id,c.quantity, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)e group by pizza_type_id )f order by tot_pizz_ordered desc

-- Q6: The quantity of each pizza categories ordered?

--Here we can see the category column is available in the pizza_types table while the quantity is available in the order_details table.
--But, the two cant be joined directly because there is no common column between the order_details table and the pizza_types table.
--Hence, we'll first inner join order_details_pizza and the pizzas table based on pizza_id colmn. Then from this we'll inner join this
--obtained table with the pizza_types table as the category colmn is available in this table. And now from this 
--we'll determine the quantity for each category.

select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id

select pizza_id,c.quantity, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id
--Now from this we'll inner join this obtained table with the pizza_types table as the category colmn is available in this table.



select e.category, sum(e.quantity) as Tot_Quantity from
(select pizza_id,c.quantity, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id) e group by e.category order by Tot_Quantity desc

--And now finally from this we'll determine the quantity for each category.

-- Q7: The distribution of orders by hours of the day.

--here first we'll join order_details_pizza and the orders_pizza tables based on common order_id
select a.order_id, pizza_id,b.date,b.time from order_details_pizza a inner join orders_pizza b on a.order_id = b.order_id

--Next we'll create a time interval using datepart to create an hourly time interval and from this we'll select the order_id,
-- time_interval, and count of the time interval to find the distribution of orders w.r.t hours
select  order_id, concat(DATEPART(hh,time),'-',DATEPART(hh,time)+1,'hr') as time_interval from
(select a.order_id, pizza_id,b.date,b.time from order_details_pizza a inner join orders_pizza b on a.order_id = b.order_id)c

--Finally
select d.order_id,d.time_interval,count(d.time_interval) from
(select  order_id, concat(DATEPART(hh,time),'-',DATEPART(hh,time)+1,'hr') as time_interval from
(select a.order_id, pizza_id,b.date,b.time from order_details_pizza a inner join orders_pizza b on a.order_id = b.order_id)c)d
group by d.order_id, d.time_interval order by d.order_id asc
--ALITER

select d.order_id,d.time_interval,count(d.time_interval) as cnt_of_orders from
(select  order_id, concat(DATEPART(hh,time),'-',DATEPART(hh,time)+1,'hr') as time_interval from
(select a.order_id, pizza_id,b.date,b.time from order_details_pizza a inner join orders_pizza b on a.order_id = b.order_id)c)d
group by d.time_interval,d.order_id order by d.time_interval,d.order_id asc

--ALITER OR ADDITIONALLY THIS GIVES THE TOTAL ORDERS FOR EACH TIME INTERVAL OF THE DAY ( WHICH IS DESIRED)

select e.time_interval, sum(e.cnt_of_orders) as total_orders from
(select d.order_id,d.time_interval,count(d.time_interval) as cnt_of_orders from
(select  order_id, concat(DATEPART(hh,time),'-',DATEPART(hh,time)+1,'hr') as time_interval from
(select a.order_id, pizza_id,b.date,b.time from order_details_pizza a inner join orders_pizza b on a.order_id = b.order_id)c)d
group by d.time_interval,d.order_id )e group by e.time_interval order by time_interval asc

-- Q8: The category-wise distribution of pizzas

--Here, we can use the previous queries obtained for Q6 using which we have joined order_details_pizza and pizzas tables 
select pizza_id,c.quantity, c.pizza_type_id,d.category from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id

select  d.category,count(c.pizza_type_id) as pizza_count from
(select quantity, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id group by d.category ORDER BY pizza_count DESC;

-- Q9: The average number of pizzas ordered per day.

--Here we'll first join orders_details_pizza and the pizzas tables 
select quantity,a.pizza_id,price, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id

--now we'll join the table obtained above and the pizza_types
select order_id,c.quantity, c.pizza_type_id from
(select quantity,order_id,price, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id

--now we'll join the above table with the orders_pizza table so as to get date and Quantity column in one table 
select d.order_id,date,quantity,pizza_type_id from
(select order_id,c.quantity, c.pizza_type_id from
(select quantity,order_id, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)d inner join orders_pizza e on d.order_id = e.order_id

--now we'll find the sum of quantity for each day, which will be used to obtain 
--the final average value of the pizzas per day using the AVG Function 
select date,sum(quantity) as sm from
(select order_id,c.quantity, c.pizza_type_id from
(select quantity,order_id, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)d inner join orders_pizza e on d.order_id = e.order_id group by date

--Finally using the fomula
select AVG(sm) as avg_pizzas_per_day from
(select date,sum(quantity) as sm from
(select order_id,c.quantity, c.pizza_type_id from
(select quantity,order_id, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)d inner join orders_pizza e on d.order_id = e.order_id group by date)f

--ALITER to calculate the average number of pizzas ordered per day we directly can use the AVG function by using the 
--results obtained with CTE Expressions
WITH DailyPizzaOrders AS (
select date,sum(quantity) as sm from
(select order_id,c.quantity, c.pizza_type_id from
(select quantity,order_id, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)d inner join orders_pizza e on d.order_id = e.order_id group by date
)SELECT AVG(sm) AS avg_pizzas_per_day FROM DailyPizzaOrders;

-- Q10: Top 3 most ordered pizza type based on revenue.

--Here first we need to join the order_details_pizza and the pizzas tables based on the pizza_id as the order_details_pizza include
--the quantity of the pizzas sold and the pizzas table include the respective prices for each pizzas. Just like the Q2

select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id

--After joining, we now need to add another column that helps find the revenue generated from each pizza_id wiz = quantity*price, So

select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c

--Further, to add names of the respective pizzas along with their types when calculating the revenue, we can join the table obtained
--above with the pizza_types table
select d.pizza_type_id,name, price,quantity,revenue from
(select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d inner join pizza_types e
on d.pizza_type_id = e.pizza_type_id

--Now the revenue column can be summed and grouped by pizza_type_id to generate total revenue generated  
select pizza_type_id,name,sum(revenue) as Total_Revenue from
(select d.pizza_type_id,name, price,quantity,revenue from
(select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d inner join pizza_types e
on d.pizza_type_id = e.pizza_type_id)f group by pizza_type_id,name order by Total_Revenue desc

--Now Finally the Top 3 pizzas types based on revenue
select top 3* from
(select pizza_type_id,name,sum(revenue) as Total_Revenue from
(select d.pizza_type_id,name, price,quantity,revenue from
(select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d inner join pizza_types e
on d.pizza_type_id = e.pizza_type_id)f group by pizza_type_id,name)g order by Total_Revenue desc

-- Q11: The percentage contribution of each pizza type to revenue.

--For this we'll divide revenue obtained for each pizza type as available in the Total_Revenue column with grand Total i.e. the sum of
-- the revenue for all the pizza types
select sum(revenue) as Grand_Total_Revenue from
(select pizza_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d

select pizza_type_id,name,Total_Revenue/(select sum(revenue) as Grand_Total_Revenue from
(select pizza_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d)*100 as percentage_contribution from
(select pizza_type_id,name,sum(revenue) as Total_Revenue from
(select d.pizza_type_id,name, price,quantity,revenue from
(select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d inner join pizza_types e
on d.pizza_type_id = e.pizza_type_id)f group by pizza_type_id,name)g  order by Total_Revenue desc

-- Q12: The cumulative revenue generated over time.

--Here first we'll join the tables order_details_pizza and the pizzas so as to get quantity and the price in one table
select order_id,c.quantity, price, c.pizza_type_id,d.category from
(select quantity,order_id,price, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id

--now we'll join the above table with the orders_pizza table so as to get date column in one table alongwith the quantity and the
-- the price using which well we'll find the daily revenue sorted by each day
--find the sum of quantity  wr.t each day,
select date,quantity,price,'daily_reve' = quantity*price,pizza_type_id from
(select order_id,c.quantity, price, c.pizza_type_id,d.category from
(select quantity,order_id,price, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)d inner join orders_pizza e on d.order_id = e.order_id

--Here now we'll sum the daily revenue corressponding to each day
select  f.date,sum(daily_reve) as DailyRevenue from
(select date,quantity,price,'daily_reve' = quantity*price,pizza_type_id from
(select order_id,c.quantity, price, c.pizza_type_id,d.category from
(select quantity,order_id,price, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b on a.pizza_id = b.pizza_id) c
inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)d inner join orders_pizza e on d.order_id = e.order_id)f
group by date order by date asc


--Finally we'll sum the daily revenue and order by date to find the cummulative revenue 
select date,DailyRevenue,sum(DailyRevenue) over (order by date asc) as CumulativeRevenue from
(select  f.date,sum(daily_reve) as DailyRevenue from
(select date,quantity,price,'daily_reve' = quantity*price,pizza_type_id from
(select order_id,c.quantity, price, c.pizza_type_id,d.category from
(select quantity,order_id,price, a.pizza_id, pizza_type_id,size from order_details_pizza a inner join pizzas b 
on a.pizza_id = b.pizza_id) c inner join pizza_types d on c.pizza_type_id = d.pizza_type_id)d inner join orders_pizza e
on d.order_id = e.order_id)f group by date) g order by date asc;

-- Q13: The top 3 most ordered pizza type based on revenue for each pizza category.

--Here first we need to join the order_details_pizza and the pizzas tables based on the pizza_id as the order_details_pizza include
--the quantity of the pizzas sold and the pizzas table include the respective prices for each pizzas. Just like the Q2

select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id

--After joining, we now need to add another column that helps find the revenue generated from each pizza_id wiz = quantity*price, So

select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c

--Further, to add names and category of the respective pizzas along with their types when calculating the revenue, we can join the table obtained
--above with the pizza_types table
select d.pizza_type_id,name,category, price,quantity,revenue from
(select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d inner join pizza_types e
on d.pizza_type_id = e.pizza_type_id

--Now the revenue column can be summed and grouped by category to generate total revenue generated by each pizza category
select category,sum(revenue) as Total_Revenue from
(select d.pizza_type_id,name,category, price,quantity,revenue from
(select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d inner join pizza_types e
on d.pizza_type_id = e.pizza_type_id)f group by category order by Total_Revenue desc

--FINALLY, SELECTING THE TOP 3 CATEGORIES BY REVENUE
select top 3* from
(select category,sum(revenue) as Total_Revenue from
(select d.pizza_type_id,name,category, price,quantity,revenue from
(select pizza_type_id, quantity, price, 'revenue' = quantity*price from
(select order_details_id,order_id, a.pizza_id,size,pizza_type_id,quantity, price from 
order_details_pizza a inner  join pizzas b on a.pizza_id = b.pizza_id)c)d inner join pizza_types e
on d.pizza_type_id = e.pizza_type_id)f group by category)h  order by Total_Revenue desc

