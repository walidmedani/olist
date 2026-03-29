with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

sellers as (
    select * from {{ ref('stg_sellers') }}
),

orders as (
    select
        order_id,
        order_purchase_date,
        order_status
    from {{ ref('stg_orders') }}
)

select
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value as total_item_value,
    p.product_category_name_english,
    s.seller_city,
    s.seller_state,
    o.order_purchase_date,
    o.order_status
from order_items oi
left join products p on oi.product_id = p.product_id
left join sellers s on oi.seller_id = s.seller_id
left join orders o on oi.order_id = o.order_id
