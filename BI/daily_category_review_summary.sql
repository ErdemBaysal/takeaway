create or replace view daily_category_review_summary as
select
        dc.category_level_1 as category,
        f.product_sk as product_sk,
        f.reviewer_sk,
        review_date,
        overall as rating
from fact_review f
inner join dim_product dp on f.product_sk = dp.product_sk
inner join dim_category dc on dp.category_sk = dc.category_sk
;
