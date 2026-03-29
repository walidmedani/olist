select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    price,
    freight_value,

    -- dbt calculates derived columns (cleaning/enrichment)
    price + freight_value as total_item_value

from {{ source('olist_dwh', 'order_items') }}
where order_id is not null
  and price >= 0          -- dbt removes bad data
  and freight_value >= 0