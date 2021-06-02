create or replace procedure etl_lnk_relative_product(
   etl_date date
)
language plpgsql    
as $$
begin
-- full refresh

truncate table lnk_relative_product;

insert into lnk_relative_product
select 
	dp.product_sk,
	dpr.product_sk as relative_product_sk,
	relative_type,
	current_timestamp as dwh_insert_date
from
(
	select 
		asin as product_id,
		unnest(also_viewed) as relative_product_id,
		'also_viewed' as relative_type
	from stage_metadata
	union all
	select 
		asin as product_id,
		unnest(also_bought) as relative_product_id,
		'also_bought' as relative_type
	from stage_metadata
	union all
	select 
		asin as product_id,
		unnest(bought_together) as relative_product_id,
		'bought_together' as relative_type,
	from stage_metadata
	
) s
left outer join dim_product dp on s.product_id = dp.product_id and dp.active_flag='Y'
left outer join dim_product dpr on s.relative_product_id = dpr.product_id and dp.active_flag='Y'
;

    commit;
end;$$