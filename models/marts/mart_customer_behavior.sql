with orders as (

    select * from {{ ref('int_orders_enriched') }}

),

final as (

    select
        customer_id,
        customer_city,
        customer_state,

        count(order_id)                     as total_orders,
        round(sum(total_order_value), 2)    as total_spent,
        round(avg(total_order_value), 2)    as avg_order_value,
        round(avg(review_score), 2)         as avg_review_score,
        min(ordered_at)                     as first_order_at,
        max(ordered_at)                     as last_order_at,

        sum(case when order_status = 'delivered' then 1 else 0 end) as delivered_orders,
        sum(case when order_status = 'canceled'  then 1 else 0 end) as canceled_orders,

        case
            when count(order_id) = 1 then 'One Time'
            when count(order_id) between 2 and 3 then 'Repeat'
            else 'Loyal'
        end as customer_segment

    from orders
    group by customer_id, customer_city, customer_state

)

select * from final