select
        category,
        review_date,
        round(avg(rating),2) as avg_rating,
        count(8) as review_count,
        count(distinct product_sk) as reviewed_product_count,
        count(distinct reviewer_sk) as distinct_reviewer_count
from daily_category_review_summary
group by 1,2
