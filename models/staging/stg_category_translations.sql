with source as (

    select * from {{ ref('product_category_name_translation') }}

),

staged as (

    select
        product_category_name         as category_name_portuguese,
        product_category_name_english as category_name_english

    from source

)

select * from staged