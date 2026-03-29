-- This test fails if any item has a negative price
-- dbt expects this query to return 0 rows for the test to pass
select
    order_id,
    price
from {{ ref('stg_order_items') }}
where price < 0
