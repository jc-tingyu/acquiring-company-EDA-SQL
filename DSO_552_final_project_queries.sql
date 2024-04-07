--Q1
select count(distinct(id)) from accounts;

--Q2
select count(distinct(r.name)) from region r;

--Q3
--a. They sell 3 types of paper

select round(100*sum(standard_qty)/sum(total), 3) Standard_percentage,
  round(100*sum(gloss_qty)/sum(total), 3) Gloss_percentage,
  round(100*sum(poster_qty)/sum(total), 3) Poster_percentage
  
from orders;
--b
select round(100*sum(standard_amt_usd)/sum(total_amt_usd), 3) Standard_revenue_percentage,
  round(100*sum(gloss_amt_usd)/sum(total_amt_usd), 3) Gloss_renevue_percentage,
  round(100*sum(poster_amt_usd)/sum(total_amt_usd), 3) Poster_renevue_percentage
from orders;



--Q4
--a
select extract(year from occurred_at) as year, 
sum(total_amt_usd) total_revenue
from orders 
where extract(year from occurred_at) in 
(select distinct(extract(year from occurred_at)))
group by year
having count( distinct(extract(month from occurred_at))) =12
order by year;

--b
select extract(year from occurred_at) as year, 
sum(total) total_unit
from orders 
where extract(year from occurred_at) in 
(select distinct(extract(year from occurred_at)))
group by year
having count( distinct(extract(month from occurred_at))) =12
order by year;

--Q5
select name, (select count(id) from sales_reps sr
where sr.region_id = re.id) total_value
								 from region re
								 order by name
-- Q6
-- a)
select r.name, count(distinct o.id) as Total_Orders, 
count(distinct sr.id) as Total_Reps, count(distinct a.id) as Total_Accounts, 
sum(o.total_amt_usd) as Total_Rev, avg(o.total_amt_usd) as Average_Rev
from region r
right join sales_reps sr on r.id=sr.region_id
right join accounts a on a.sales_rep_id=sr.id
full join orders o on o.account_id=a.id
where extract (year from o.occurred_at) = '2016' 
group by r.name;

-- b)
select r.name, count(distinct o.id)/count(distinct sales_rep_id) as AverageOrdRep,
count(distinct a.id)/count(distinct sales_rep_id) as AverageAccRep,
sum(o.total_amt_usd)/count(distinct sales_rep_id) as AvgRevRep
from region r
right join sales_reps sr on r.id=sr.region_id
right join accounts a on a.sales_rep_id=sr.id
full join orders o on o.account_id=a.id
where extract(year from o.occurred_at) = '2016'
group by r.name
order by AvgRevRep asc; 

-- c) I would reallocate Midwest sales reps to cover new regions because the midwest is doing very poorly
-- compared to other regions
--Q7 
select gt.group_type, avg(total_revenue)
from (select o.account_id, sum(o.total_amt_usd) avg_total_revenue
	  from orders o
	  group by o.account_id) tr
left join (select a.id,
		   case 
		   	when lower(right(a.name,5)) = 'group' then 'group'
		   	else 'not_group'
		   end group_type
		   from accounts a) as gt on tr.account_id=gt.id
group by gt.group_type;

-- Q8
select r.name, w.channel, count(w.channel) as Channel_count, 
rank() over(partition by r.name order by count(*) desc) as usage_rank
from region r
right join sales_reps sr on r.id=sr.region_id
right join accounts a on a.sales_rep_id=sr.id
right join web_events w on a.id=w.account_id
group by r.name, w.channel;
-- They should deactivate banner in Midwest, Twitter in Northeast, Twitter in Southeast, and Banner in West.
