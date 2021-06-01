create or replace view daily_category_prices
as
select
	dc.category_level_1 as category,
	f.valid_date as date,
	round(avg(f.price),2) as average_price,
	case 
		when round(avg(f.price),2) < 10 then 'A.<10'
		when round(avg(f.price),2) < 20 then 'B.10-19'
		when round(avg(f.price),2) < 30 then 'C.20-29'
		else 'D.30+'
	end price_bucket
from fact_product_price f
inner join dim_product dp on f.product_sk = dp.product_sk
inner join dim_category dc on dp.category_sk = dc.category_sk
group by 1,2
;