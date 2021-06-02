create or replace procedure etl_dim_reviewer(
   etl_date date
)
language plpgsql    
as $$
begin

-- step-1 is to truncate temp table
truncate table temp_dim_reviewer;

-- step-2 populate temp table with update_strategy labels
insert into temp_dim_reviewer
select 
	s.reviewerid as reviewer_id,
	s.reviewername as reviewer_name,
	current_timestamp as dwh_insert_date,
	null as dwh_update_date,
	case 
		when d.reviewer_sk is null then 'I' -- insert
		when md5(s.reviewername) <> md5(d.reviewer_name) then 'U' --update
		else 'N' --do nothing
	END as  update_strategy
from
(
	select 
		reviewerid,
		max(reviewername) as reviewername
	from stage_review
	where to_timestamp(unixreviewtime)::date >= etl_date 
	group by reviewerid
) s
left outer join dim_reviewer d 
on s.reviewerid = d.reviewer_id
;

-- step-3 populate dimension table

-- inserts
insert into dim_reviewer 
select 
	nextval('reviewer') as reviewer_sk,
	reviewer_id,
	reviewer_name,
	current_timestamp as dwh_insert_date
from temp_dim_reviewer
where update_strategy = 'I'
;

-- updates
update dim_reviewer 
set reviewer_name = t.reviewer_name,
	dwh_update_date = current_timestamp
from temp_dim_reviewer t
where t.update_strategy = 'U' and dim_reviewer.reviewer_id = t.reviewer_id
;

commit;


end;$$