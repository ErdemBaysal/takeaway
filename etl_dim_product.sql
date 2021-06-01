
create or replace procedure etl_dim_product(
   etl_date date
)
language plpgsql    
as $$
begin

-- step-1 is to truncate temp table

truncate table temp_dim_product;

-- step-2 populate temp table with related update_strategy labels

insert into temp_dim_product
select
	dp.product_sk,
	s.product_id,
	s.title,
	s.brand,
	s.price,
	coalesce(dc.category_sk,-99) as category_sk,
	current_timestamp as dwh_insert_date,
	null as dwh_update_date,
	case 
		when dp.product_sk is null then 'I' --inserts for new records
		when md5(concat(COALESCE(s.title,'XXX999'),COALESCE(s.brand,'XXX999'),COALESCE(s.price::text,'XXX999'))) 
			<> md5(concat(COALESCE(dp.title,'XXX999'),COALESCE(dp.brand,'XXX999'),COALESCE(dp.price::text,'XXX999'))) 
		then 'U' --updates for existing records type-1 fields
		when COALESCE(dc.category_sk,'-99') <> dp.category_sk then '2' --type2 changes, both Insert and Update
		else 'N' --do nothing
	end update_strategy
from
(
	select
	product_id,
	title,
	brand,
	price,
	md5(concat(COALESCE(s.category_level_1,'XXX999'),COALESCE(s.category_level_2,'XXX999'),COALESCE(s.category_level_3,'XXX999'),COALESCE(s.category_level_4,'XXX999'),COALESCE(s.category_level_5,'XXX999'),COALESCE(s.category_level_6,'XXX999'),COALESCE(s.category_level_7,'XXX999'))) as category_md5
	from (
		select 
			-- assumption: asin is unique
			asin as product_id,
			title,
			brand,
			price,
			categories[1][1] as category_level_1,
			categories[1][2] as category_level_2,
			categories[1][3] as category_level_3,
			categories[1][4] as category_level_4,
			categories[1][5] as category_level_5,
			categories[1][6] as category_level_6,
			categories[1][7] as category_level_7
		from stage_metadata
		) s
) s
left outer join dim_category dc --possible performance enhancement if we keep md5 hash directly on the dimension table
on s.category_md5 = md5(concat(COALESCE(dc.category_level_1,'XXX999'),COALESCE(dc.category_level_2,'XXX999'),COALESCE(dc.category_level_3,'XXX999'),COALESCE(dc.category_level_4,'XXX999'),COALESCE(dc.category_level_5,'XXX999'),COALESCE(dc.category_level_6,'XXX999'),COALESCE(dc.category_level_7,'XXX999')))
left outer join dim_product dp
on s.product_id = dp.product_id and dp.active_flag = 'Y'
;

-- step-3 apply update strategy

-- step-3.1 type-1 updates
update dim_product d
set title = t.title,
	brand = t.brand,
	price = t.price,
	dwh_update_date = current_timestamp
from temp_dim_product t
where t.update_strategy='U' and d.product_sk=t.product_sk
;

-- step-3.2 type-2 updates
update dim_product d
set 
	eff_end_date = etl_date -1,
	active_flag='N',
	dwh_update_date = current_timestamp
from temp_dim_product t 
where t.update_strategy='2' and d.product_sk=t.product_sk
;

-- step-3.3 new record and type-2 inserts
insert into dim_product
select 
	nextval('product') as product_sk,
	product_id,
	title,
	brand,
	price,
	category_sk,
	etl_date as eff_start_date,
	'2099-12-31' as eff_end_date,
	'Y' as active_flag,
	current_timestamp as dwh_insert_date,
	null as dwh_update_date
from temp_dim_product
where update_strategy in ('I','2')
;

commit;


end;$$