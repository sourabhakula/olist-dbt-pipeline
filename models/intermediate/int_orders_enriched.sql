with orders as (

    select * from {{ ref('stg_orders') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

order_items as (

    select
        order_id,
        count(order_item_id)    as item_count,
        sum(price)              as total_product_value,
        sum(freight_value)      as total_freight_value,
        sum(price + freight_value) as total_order_value

    from {{ ref('stg_order_items') }}
    group by order_id

),

payments as (

    select
        order_id,
        sum(payment_value)      as total_payment_value,
        count(distinct payment_type) as payment_method_count

    from {{ ref('stg_order_payments') }}
    group by order_id

),

reviews as (

    select
        order_id,
        review_score

    from {{ ref('stg_order_reviews') }}

),

final as (

    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.ordered_at,
        o.approved_at,
        o.delivered_at,
        o.estimated_delivery_at,

        c.city                          as customer_city,
        c.state                         as customer_state,

        oi.item_count,
        oi.total_product_value,
        oi.total_freight_value,
        oi.total_order_value,

        p.total_payment_value,
        p.payment_method_count,

        r.review_score,

        datediff('day', o.ordered_at, o.delivered_at)           as delivery_days,
        datediff('day', o.delivered_at, o.estimated_delivery_at) as days_early_or_late

    from orders o
    left join customers c       on o.customer_id = c.customer_id
    left join order_items oi    on o.order_id = oi.order_id
    left join payments p        on o.order_id = p.order_id
    left join reviews r         on o.order_id = r.order_id

)

select * from final