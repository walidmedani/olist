select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,

    -- dbt standardizes text casing (cleaning)
    initcap(customer_city) as customer_city,
    upper(customer_state) as customer_state

from {{ source('olist_dwh', 'customers') }}
where customer_id is not null