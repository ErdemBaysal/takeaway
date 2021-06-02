create or replace view daily_product_summary
as
select
        dc.category_level_1 as category,
        dp.product_id as product_id,
        dp.title as product_title,
        f.valid_date as date,
        f.price as price
from fact_product_price f
inner join dim_product dp on f.product_sk = dp.product_sk
inner join dim_category dc on dp.category_sk = dc.category_sk
;
