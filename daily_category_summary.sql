create or replace view daily_category_summary as
select 
	dc.category_level_1 as category,
	review_date,
	round(avg(f.overall),2) as average_rate,
	count(8) as review_count,
	count(distinct f.product_sk) as reviewed_product_count,
	count(distinct f.reviewer_sk) as distinct_reviewer_count
from fact_review f
inner join dim_product dp on f.product_sk = dp.product_sk
inner join dim_category dc on dp.category_sk = dc.category_sk
group by 1,2
;