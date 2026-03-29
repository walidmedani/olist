with translation as (
    select * from {{ source('olist_dwh', 'category_translation') }}
)

select
    p.product_id,
    p.product_category_name,

    -- dbt handles the translation join (cleaning)
    coalesce(t.product_category_name_english, 'unknown') 
        as product_category_name_english,

    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm

from {{ source('olist_dwh', 'products') }} p
left join translation t
    on p.product_category_name = t.product_category_name
where p.product_id is not null