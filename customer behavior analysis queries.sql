select * from customer limit 20
--q1. what is the revenue gengrated by male vs female customer ?
select gender, sum(purchase_amount) as revenue
from customer
group by gender
--q2. which customer used a discount but still they spent more than average purchase amount?
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount)from customer)
--q3 which are the top 5 products with the highiest avarege review rating?
select item_purchased, ROUND(AVG(review_rating::numeric),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;
--q4 compare the average purchase Amounts between Standard and Express shipping
select shipping_type,
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

--q5 do subscribed customer spend more?compare average spend and total revenue between subscribers and non subscribers.?
select subscription_status,
COUNT(customer_id) as total_customers,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;

--q6 which 5 product has highest percentage of purchases with the discounts applied?
select item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

--q7 segment customer into new and returning and loyal based on their total number of previous purchase and show the count of easch segment?
with customer_type as (
select customer_id, previous_purchases,
case
	when previous_purchases =1 then 'New'
	when previous_purchases between 2 and 10 then 'Returning'
	else 'Loyal'
    end as customer_segment
from customer
)
select customer_segment, count(*) as "Number of Customers"
from customer_type
group by customer_segment

--q8 what are the top three mot purchased products with in each category
with item_counts as (
select category,
item_purchased,
count(customer_id )as total_orders,
ROw_number() over (partition by category order by count (customer_id)desc) as item_rank
from customer
group by category,item_purchased
)
select item_rank,category, item_purchased,total_orders
from item_counts
where item_rank <=3;
--q9 are customers are repat buyers(more than 5 previous purchases) also likely to subscribe?
select subscription_status,
count (customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status
--q10 what is the revenue contribution of each age group?
select age_group,
SUM (purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;