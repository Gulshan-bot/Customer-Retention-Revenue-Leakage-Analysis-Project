# Basic Exploration (SELECT, WHERE, JOIN)
-- 1. Which region has the highest number of Enterprise customers?
select region, COUNT(*) as customer_count 
from customers 
where customer_segment = 'Enterprise' 
group by region 
order by customer_count DESC;

-- 2. List all customers who signed up in 2024 and were acquired through 'Direct Sales'.
select customer_id, signup_date, industry 
from customers 
where signup_date between '2024-01-01' AND '2024-12-31' 
AND acquisition_channel = 'Direct Sales';

-- 3. What is the average MRR (Monthly Recurring Revenue) for each plan type?
select plan_type, ROUND(AVG(mrr), 2) as avg_mrr 
from subscriptions 
group by plan_type;

-- 4. Identify the top 5 industries by total revenue contribution.
select c.industry, SUM(s.mrr) as total_revenue 
from customers c 
join subscriptions s on c.customer_id = s.customer_id 
group by c.industry 
order by total_revenue DESC limit 5;

-- 5. Which account managers are handling more than 40 customers?
select account_manager_id, COUNT(customer_id) as handling 
from customers 
group by account_manager_id 
having handling > 40;

# Subqueries & CTEs
-- 6. Find customers whose feature usage score is above the overall average.
select customer_id, feature_usage_score  
from usage_metrics 
where (select avg(feature_usage_score) as avg_score from usage_metrics) < feature_usage_score ;

-- 7. Identify customers who have never filed a support ticket but are in the 'SMB' segment.
select customer_id From customers 
where customer_segment = 'SMB' 
AND customer_id not in (SELECT customer_id FROM usage_metrics WHERE support_tickets > 0);

-- 8. Use a CTE to calculate the total lifetime revenue paid by each customer.
with cte as 
(select customer_id , sum(amount) as total_paid 
from transactions 
where payment_status = 'PAID' 
group by customer_id)
select * from cte 
order by total_paid desc;

-- 9. Find the most recent transaction for every customer using a subquery.
select t1.* from transactions t1
where t1.transaction_date = (
    select MAX(t2.transaction_date) 
    from transactions t2 
    where t2.customer_id = t1.customer_id
);

-- 10. Which customers downgraded their plans? (Customers with multiple subscription entries)
select customer_id, COUNT(*) as sub_count 
from subscriptions 
group by customer_id 
having sub_count > 1;

# CASE Statements
-- 11. Categorize customers into 'High', 'Medium', and 'Low' based on login frequency.
select customer_id, login_count,
case 
    when login_count > 50 then 'high'
    when login_count between 20 and 50 then 'medium'
    else 'low'
end as usage_tier
from usage_metrics;

-- 12. Flag transactions as 'Urgent' if they are more than 15 days overdue.
select invoice_id, days_overdue,
case 
    when days_overdue > 15 then 'Urgent Collection'
    when days_overdue > 0 then 'Follow Up'
    else 'On Track'
end as collection_status
from transactions where payment_status != 'Paid';

-- 13. Group customers by company size into 'Small' and 'Large' buckets. 
select customer_id, 
case 
    when company_size IN ('1-50', '51-200') then 'Small/Mid Business'
    ELSE 'large/Enterprise'
end as size_category
from customers;

-- 14. Create a "Churn Risk Score" based on NPS scores.
select customer_id, nps_score,
case 
    when nps_score <= 6 then 'Detractor'
    when nps_score between 7 and 8 then 'Passive'
    else 'Promoter'
end as nps_category
from usage_metrics;

# Window Functions
-- 15. Rank customers by their MRR within each region.
select region, customer_id, mrr,
rank() OVER (partition by region order by mrr DESC) as mrr_rank
from customers c
join subscriptions s ON c.customer_id = s.customer_id; 

-- 16.Calculate the cumulative revenue for the company over time.
select transaction_date, amount,
SUM(amount) over (order by transaction_date) as running_total_revenue
from transactions where	 payment_status = 'Paid';


-- 17. Find the difference in MRR between a customer's current and previous subscription.
select customer_id, plan_type, mrr,
mrr - lag(mrr) over (partition by customer_id order by start_date) as mrr_change
FROM subscriptions;

# bouns 
-- 18. What is the total revenue lost (leakage) from failed and pending payments?
select SUM(amount) as leaked_revenue 
from transactions 
where payment_status in ('Failed', 'Pending');

-- 19. Identify the top 3 reasons for churn among Enterprise customers.
select churn_reason, COUNT(*) as reason_count
from subscriptions s
join customers c ON s.customer_id = c.customer_id
where c.customer_segment = 'Enterprise' and churn_date is not null
group by churn_reason
order by reason_count desc limit 3;

-- 20: Display customer count by segment with descriptive text
--     #   Output: "There are a total of 80 enterprise customers."
select 
    concat('There are a total of ', COUNT(*), ' ', LOWER(customer_segment), ' customers.') AS summary
from customers
group by customer_segment
order by COUNT(*), customer_segment;

-- 21 : Show subscription plan distribution with formatted output
--        # Output: "The Basic plan has 150 active subscriptions."
select 
    CONCAT('The ', plan_type, ' plan has ', COUNT(*), ' active subscriptions.') AS plan_summary
from subscriptions
where churn_date is null
group by plan_type
order by COUNT(*) desc;

-- # Gulshan Soni #-- 