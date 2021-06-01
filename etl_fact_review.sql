
create or replace procedure etl_fact_review(
   etl_date date
)
language plpgsql    
as $$
begin

-- delete the existing fact records afte the etl_date
-- fact tables can be partitioned and related partitions can be refreshed

delete from fact_review where review_date >= etl_Date;

insert into fact_review
select 
	coalesce(dp.product_sk,-99),
	coalesce(dr.reviewer_sk,-99),
	s.overall,
	coalesce(s.helpful[1],0) as helpful_yes_count,
	coalesce(s.helpful[2],0) as helpful_count,
	to_timestamp(s.unixreviewtime)::date as review_date,
	current_timestamp as dwh_insert_date
from stage_review s
left outer join dim_product dp on s.asin = dp.product_id and to_timestamp(s.unixreviewtime)::date between dp.eff_start_date and dp.eff_end_date
left outer join dim_reviewer dr on s.reviewerid = dr.reviewer_id 
where to_timestamp(s.unixreviewtime)::date >= etl_date
;
commit;


end;$$