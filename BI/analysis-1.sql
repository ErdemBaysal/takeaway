-- query to analyse category price measures

select 
        category,
        date,
        round(avg(price),2) as avg_price,
        case
                when round(avg(price),2) < 10 then 'A.<10'
                when round(avg(price),2) < 20 then 'B.10-19'
                when round(avg(price),2) < 30 then 'C.20-29'
                else 'D.30+'
        end avg_price_bucket,
        round(min(price),2) as min_price,
        case
                when round(min(price),2) < 10 then 'A.<10'
                when round(min(price),2) < 20 then 'B.10-19'
                when round(min(price),2) < 30 then 'C.20-29'
                else 'D.30+'
        end as min_price_bucket,
        round(max(price),2) as max_price,
        case
                when round(max(price),2) < 10 then 'A.<10'
                when round(max(price),2) < 20 then 'B.10-19'
                when round(max(price),2) < 30 then 'C.20-29'
                else 'D.30+'
        end as max_price_bucket
from daily_product_summary
group by 1,2;
