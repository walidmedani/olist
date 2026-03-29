select
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    -- dbt handles the date extraction (cleaning)
    date(order_purchase_timestamp) as order_purchase_date,

    -- calculate delivery time in days (business logic in dbt)
    date_diff(
        date(order_delivered_customer_date),
        date(order_purchase_timestamp),
        day
    ) as delivery_days

from {{ source('olist_dwh', 'orders') }}

-- dbt handles null filtering (cleaning)
where order_id is not null
  and customer_id is not null