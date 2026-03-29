select
    review_id,
    order_id,
    review_score,
    review_creation_date,
    review_answer_timestamp

from {{ source('olist_dwh', 'order_reviews') }}
where order_id is not null
  and review_score between 1 and 5  -- dbt removes invalid scores