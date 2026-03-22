# Olist E-Commerce dbt Pipeline

open olist_pipeline/ to see the full project.

I wanted minutely mimic how data teams actually structure SQL transformations at 
companies like Airbnb or Uber, not just write queries against a flat table 
and call it a project. So I took a real dataset, 100,000+ orders from Olist, 
a Brazilian e-commerce marketplace, and built a proper layered pipeline using 
dbt and DuckDB.

The dataset is public on Kaggle. Olist published their actual transaction data 
including orders, customers, sellers, payments and reviews. I used dbt to 
transform that raw data into business-ready tables following the staging to 
intermediate to marts pattern you see in production data teams.

The pipeline has three layers and each one has a specific job. Staging is just 
cleaning. Rename columns, cast dates from text to timestamps, nothing else. 
Intermediate is where joins happen and business logic gets applied. Marts are 
the final tables a BI tool connects to. Three of them, one for order performance, 
one for seller performance, one for customer behavior.

The thing that changed how I think about SQL was the ref() function. Instead 
of hardcoding table names you reference other models and dbt builds a dependency 
graph automatically. It figures out what order to run everything in. You stop 
thinking in individual queries and start thinking in data flows. That shift is 
what analytics engineering actually is and I did not fully get it until I built 
this.

I also wrote 17 data tests. Every primary key tested for uniqueness and nulls. 
Order status validated against an accepted values list so if something unexpected 
shows up in the source data the pipeline breaks loudly instead of silently passing 
bad data downstream. Most portfolio projects skip this. I did not because in a 
real job untested pipelines are liabilities.


staging layer, 8 views

| model | what it does |
|-------|-------------|
| stg_orders | cleans order timestamps and standardizes status values |
| stg_customers | customer city and state with clean column names |
| stg_order_items | line items with price and freight per order |
| stg_order_payments | payment type, installments and value per order |
| stg_order_reviews | review scores and timestamps |
| stg_products | product dimensions and category in portuguese |
| stg_sellers | seller location data |
| stg_category_translations | maps portuguese category names to english |

intermediate layer, 2 views

| model | what it does |
|-------|-------------|
| int_orders_enriched | joins orders, customers, items, payments and reviews into one row per order. calculates delivery days and days early or late vs estimated date |
| int_seller_metrics | aggregates all order activity to one row per seller with revenue, review scores and cancellation counts |

marts layer, 3 tables

| model | what it does |
|-------|-------------|
| mart_order_performance | adds delivery status and review sentiment flags to every order |
| mart_seller_performance | scores every seller as top, average, or underperforming based on review score and cancellation rate |
| mart_customer_behavior | segments every customer as one time, repeat, or loyal based on order frequency |


to run it yourself:

    pip install dbt-duckdb
    dbt seed
    dbt run
    dbt test
    dbt docs generate
    dbt docs serve

dataset: Olist Brazilian E-Commerce on Kaggle
tools: dbt Core 1.11, DuckDB, SQL
models: 11, tests: 17, seeds: 9
