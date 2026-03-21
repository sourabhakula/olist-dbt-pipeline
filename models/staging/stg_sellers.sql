with source as (

    select * from {{ ref('olist_sellers_dataset') }}

),

staged as (

    select
        seller_id,
        seller_zip_code_prefix  as zip_code,
        seller_city             as city,
        seller_state            as state

    from source

)

select * from staged