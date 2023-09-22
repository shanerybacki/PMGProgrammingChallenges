-- PMG SQL Assessment


-- Creating the tables
	-- Note: I changed the name of the table given in the code to match with the CSV
create table marketing_performance (
 date datetime,
 campaign_id varchar(50),
 geo varchar(50),
 cost float,
 impressions float,
 clicks float,
 conversions float
);


create table website_revenue (
 date datetime,
 campaign_id varchar(50),
 state varchar(2),
 revenue float
);

create table campaign_info (
 id int not null primary key auto_increment,
 name varchar(50),
 status varchar(50),
 last_updated_date datetime
);



-- 1) Write a query to get the sum of impressions by day.
select date_format(date, '%Y-%m-%d') as 'date', sum(impressions) as 'total_impressions'
from marketing_performance
group by date
order by date asc;

-- 2) Write a query to get the top three revenue-generating states in order of best to worst. How much revenue did the third best state generate?
select state, sum(revenue) as 'total_revenue'
from website_revenue
group by state
order by total_revenue desc
limit 3;
	-- The third best state, Ohio, generated revenue of $37,577

-- 3) Write a query that shows total cost, impressions, clicks, and revenue of each campaign. Make sure to include the campaign name in the output.
with campaign_mp as(
	select campaign_id, round(sum(cost), 2) as 'cost', sum(impressions) as 'impressions', sum(clicks) as 'clicks'
	from marketing_performance
	group by campaign_id),
campaign_wr as (
	select campaign_id, sum(revenue) as 'revenue'
	from website_revenue
	group by campaign_id)
select i.name, mp.cost, mp.impressions, mp.clicks, wr.revenue
from campaign_info i
left join campaign_mp mp on mp.campaign_id = i.id
left join campaign_wr wr on wr.campaign_id = i.id
order by name asc;

-- 4) Write a query to get the number of conversions of Campaign5 by state. Which state generated the most conversions for this campaign?
select right(geo, 2) as 'state', sum(conversions) as 'total_conversions'
from marketing_performance mp
left join campaign_info ci on ci.id = mp.campaign_id
where ci.name = 'Campaign5'
group by geo
order by total_conversions desc;
	-- Georgia generated the most conversions for Campaign5.
    
-- 5) In your opinion, which campaign was the most efficient, and why?
with campaign_mp as(
	select campaign_id, round(sum(cost), 2) as 'cost', 
		sum(impressions) as 'impressions', 
        sum(clicks) as 'clicks',
        sum(conversions) as 'conversions'
	from marketing_performance
	group by campaign_id),
campaign_wr as (
	select campaign_id, sum(revenue) as 'revenue'
	from website_revenue
	group by campaign_id)
select i.name as 'campaign', 
	round(100 * (wr.revenue / mp.cost), 2) as 'roas', 
	round(100 * (mp.clicks / mp.impressions), 2) as 'ctr',
    round(100 * (mp.conversions / mp.clicks), 2) as 'conversion_rate'
from campaign_info i
left join campaign_mp mp on mp.campaign_id = i.id
left join campaign_wr wr on wr.campaign_id = i.id
order by name asc;
	-- I analyzed three key metrics: Return on ad spend (ROAS), click-through rate (CTR), and conversion rate.  
	-- I believe that businesses at their core are meant to turn a profit, so I tend to place higher preference towards metrics like ROI, etc.
    -- So, it would seem that I would heavily weigh ROAS when evaluating a campaign's efficiency.
    -- However, we are only given the costs of the campaigns themeslves, not any other associated costs. 
    -- So, I actually would put more weight on CTR and conversion rate.
    -- Of these two, I think conversion_rate is a better metric because it looks at who actually becomes paying customers as opposed to who simply looks at a page.
    -- So, I believe that, even though it has a lower ROAS, Campaign3 was the most efficient because it has the tied highest conversion rate as well as a middle of the road CTR.
    
-- 6) Write a query that showcases the best day of the week (e.g., Sunday, Monday, Tuesday, etc.) to run ads.
select dayname(date) as 'day_of_week', round(100 * (sum(conversions) / sum(clicks)), 2) as 'conversion_rate'
from marketing_performance
group by dayname(date)
order by conversion_rate desc;
	-- As discussed in 5), I believe that conversion rate is the best metric for assessing the efficiency of a marketing campaign (at least with the provided data).
    -- Friday is the day of the week with the highest conversion rate, so I believe Friday is the best day to run ads.