with order_items as (

    select * from {{ ref('stg_order_items') }}

),

orders as (

    select
        order_id,
        order_status,
        ordered_at

    from {{ ref('stg_orders') }}

),

reviews as (

    select
        order_id,
        review_score

    from {{ ref('stg_order_reviews') }}

),

sellers as (

    select * from {{ ref('stg_sellers') }}

),

products as (

    select
        product_id,
        category_name_portuguese

    from {{ ref('stg_products') }}

),

translations as (

    select * from {{ ref('stg_category_translations') }}

),

joined as (

    select
        oi.seller_id,
        oi.order_id,
        oi.product_id,
        oi.price,
        oi.freight_value,
        o.order_status,
        o.ordered_at,
        r.review_score,
        s.city                          as seller_city,
        s.state                         as seller_state,
        coalesce(t.category_name_english, p.category_name_portuguese) as category_name

    from order_items oi
    left join orders o          on oi.order_id = o.order_id
    left join reviews r         on oi.order_id = r.order_id
    left join sellers s         on oi.seller_id = s.seller_id
    left join products p        on oi.product_id = p.product_id
    left join translations t    on p.category_name_portuguese = t.category_name_portuguese

),

final as (

    select
        seller_id,
        seller_city,
        seller_state,
        count(distinct order_id)                                    as total_orders,
        count(distinct product_id)                                  as unique_products,
        round(sum(price), 2)                                        as total_revenue,
        round(avg(price), 2)                                        as avg_order_value,
        round(avg(review_score), 2)                                 as avg_review_score,
        sum(case when order_status = 'delivered' then 1 else 0 end) as delivered_orders,
        sum(case when order_status = 'canceled' then 1 else 0 end)  as canceled_orders

    from joined
    group by seller_id, seller_city, seller_state

)

select * from final