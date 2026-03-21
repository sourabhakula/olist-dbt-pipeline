with source as (

    select * from {{ ref('olist_order_reviews_dataset') }}

),

staged as (

    select
        review_id,
        order_id,
        review_score,
        cast(review_creation_date as timestamp)  as reviewed_at,
        cast(review_answer_timestamp as timestamp) as answered_at

    from source

)

select * from staged