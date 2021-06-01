create or replace procedure etl_fact_product_price(
   etl_date date
)
language plpgsql    
as $$
begin
   
   
   --delete the snaphot values after the etl_date
   delete from fact_product_price where valid_date >= etl_date;
   
   --insert daily snapshot values
   insert into fact_product_price
   select 
		dp.product_sk,
		s.price,
		ddate.date as valid_date,
		current_timestamp as dwh_insert_date
   from stage_metadata s
   inner join
   (
	select date 
	from dim_date
	where date between etl_date and current_date
   ) ddate on 1=1
   inner join dim_product dp on s.asin = dp.product_id and ddate.date between dp.eff_start_date and dp.eff_end_date
   ;

    commit;
end;$$