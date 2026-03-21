with sellers as (

    select * from {{ ref('int_seller_metrics') }}

),

final as (

    select
        seller_id,
        seller_city,
        seller_state,
        total_orders,
        unique_products,
        total_revenue,
        avg_order_value,
        avg_review_score,
        delivered_orders,
        canceled_orders,

        round(
            canceled_orders * 100.0 / nullif(total_orders, 0), 2
        ) as cancellation_rate_pct,

        round(
            delivered_orders * 100.0 / nullif(total_orders, 0), 2
        ) as delivery_rate_pct,

        case
            when avg_review_score >= 4 and cancellation_rate_pct <= 5  then 'Top Seller'
            when avg_review_score >= 3 and cancellation_rate_pct <= 15 then 'Average Seller'
            else 'Underperforming'
        end as seller_tier

    from sellers

)

select * from final