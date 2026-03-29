select
    seller_id,
    seller_zip_code_prefix,
    initcap(seller_city) as seller_city,
    upper(seller_state) as seller_state

from {{ source('olist_dwh', 'sellers') }}
where seller_id is not null