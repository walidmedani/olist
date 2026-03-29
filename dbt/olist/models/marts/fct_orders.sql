with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

payments as (
    select
        order_id,
        sum(payment_value) as total_payment_value,
        count(*) as payment_count
    from {{ ref('stg_order_payments') }}
    group by order_id
),

reviews as (
    select
        order_id,
        avg(review_score) as avg_review_score
    from {{ ref('stg_order_reviews') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_purchase_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_city,
    c.customer_state,
    p.total_payment_value,
    p.payment_count,
    r.avg_review_score
from orders o
left join customers c on o.customer_id = c.customer_id
left join payments p on o.order_id = p.order_id
left join reviews r on o.order_id = r.order_id
