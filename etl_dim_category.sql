
create or replace procedure etl_dim_category(
   etl_date date
)
language plpgsql    
as $$
begin

-- step-1 is to truncate temp table
truncate table temp_dim_category;

-- step-2 populate temp table with update_strategy
insert into temp_dim_category
select 
	coalesce(s.category_level_7,s.category_level_6,s.category_level_5,s.category_level_4,s.category_level_3,s.category_level_2,s.category_level_1) as category,
	s.category_level_1,
	s.category_level_2,
	s.category_level_3,
	s.category_level_4,
	s.category_level_5,
	s.category_level_6,
	s.category_level_7,
	current_timestamp as dwh_insert_date,
	null as dwh_update_date,
	case 
		when d.category_sk is null then 'I'
		else 'N'
	end as update_strategy
from 
(
	select 
		distinct --taking the first hierarchy 
		categories[1][1] as category_level_1,
		categories[1][2] as category_level_2,
		categories[1][3] as category_level_3,
		categories[1][4] as category_level_4,
		categories[1][5] as category_level_5,
		categories[1][6] as category_level_6,
		categories[1][7] as category_level_7
	from stage_metadata
) s 
left outer join dim_category d
on md5(concat(COALESCE(s.category_level_1,'XXX999'),COALESCE(s.category_level_2,'XXX999'),COALESCE(s.category_level_3,'XXX999'),COALESCE(s.category_level_4,'XXX999'),COALESCE(s.category_level_5,'XXX999'),COALESCE(s.category_level_6,'XXX999'),COALESCE(s.category_level_7,'XXX999'))) 
 = md5(concat(COALESCE(d.category_level_1,'XXX999'),COALESCE(d.category_level_2,'XXX999'),COALESCE(d.category_level_3,'XXX999'),COALESCE(d.category_level_4,'XXX999'),COALESCE(d.category_level_5,'XXX999'),COALESCE(d.category_level_6,'XXX999'),COALESCE(d.category_level_7,'XXX999'))) 
;

-- step-3 populate dimension table, since this is type-0, only inserts
insert into dim_category
select 
	nextval('category') as category_sk,
	category,
	category_level_1,
	category_level_2,
	category_level_3,
	category_level_4,
	category_level_5,
	category_level_6,
	category_level_7,
	current_timestamp as dwh_insert_date,
	null as dwh_update_date
from temp_dim_category
where update_strategy='I'
;

commit;


end;$$