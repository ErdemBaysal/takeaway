-- checks products that have anomalies (per threshold) in price for certain etl_date and compare last 7 days average price
-- etl_date as parameter: '2021-05-30'
-- threshold as parameter: 0.7

select product_sk
from (
select
        product_sk,
        sum(case
                when valid_date >= '2021-05-30'::date - 8 and valid_date <='2021-05-30'::date - 1
                then price
                else 0
        end) as last_7_sum,
        sum(case
                when valid_date >= '2021-05-30'::date - 8 and valid_date <='2021-05-30'::date - 1
                then 1
                else null
        end) as last_7_cnt,
        sum(case
                when valid_date = '2021-05-30'
                then price
                else 0
        end) as check_date_price,
        sum(case
                when valid_date = '2021-05-30'
                then 1
                else 0
        end) as check_date_exist
from fact_product_price
where valid_date >= '2021-05-30'::date - 8 and valid_date <= '2021-05-30'
group by 1
) sub
where check_date_exist >0 and abs((last_7_sum / least(7,last_7_cnt)) - check_date_price) > 0.7
;
