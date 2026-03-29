select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value

from {{ source('olist_dwh', 'order_payments') }}
where order_id is not null
  and payment_value >= 0