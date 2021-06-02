-- provides list of products that have inconsistency for also_bought and also_viewed data
-- expectation, all the products in also_bought should appear in also-viewed

select
        ab.product_sk,
        ab.relative_product_sk
from
(
select product_sk, relative_product_sk
from lnk_relative_product
where relative_type = 'also_bought'
) ab
left outer join
(
select product_sk, relative_product_sk
from lnk_relative_product
where relative_type = 'also_bought'
) av on ab.product_sk = ab.product_sk and ab.relative_product_sk = ab.relative_product_sk
where av.product_sk is null
;
