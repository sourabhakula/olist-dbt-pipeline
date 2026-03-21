with orders as (

    select * from {{ ref('int_orders_enriched') }}

),

final as (

    select
        order_id,
        customer_id,
        customer_city,
        customer_state,
        order_status,
        ordered_at,
        delivered_at,
        estimated_delivery_at,

        item_count,
        total_product_value,
        total_freight_value,
        total_order_value,
        total_payment_value,
        review_score,

        delivery_days,
        days_early_or_late,

        case
            when order_status = 'delivered' and days_early_or_late <= 0 then 'On Time'
            when order_status = 'delivered' and days_early_or_late > 0  then 'Late'
            when order_status = 'canceled'                              then 'Canceled'
            else 'Other'
        end as delivery_status,

        case
            when review_score >= 4 then 'Positive'
            when review_score = 3  then 'Neutral'
            when review_score <= 2 then 'Negative'
            else 'No Review'
        end as review_sentiment

    from orders

)

select * from final