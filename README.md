# Olist E-Commerce dbt Pipeline

I built this project to learn analytics engineering properly not just write 
SQL, but structure it the way data teams actually do it at companies like 
Airbnb, Uber, and Spotify.

The dataset is real. Olist is a Brazilian e-commerce marketplace that published 
100,000+ orders, customers, sellers, payments and reviews as open data on Kaggle. 
I used dbt and DuckDB to transform that raw data into business-ready analytical 
tables following the staging → intermediate → marts pattern you see in production 
pipelines.

---

## Why I Built This

Most portfolio projects stop at writing SQL queries. I wanted to go further and 
show that I understand how data pipelines are actually structured in a professional 
environment — with layered models, dependency tracking, automated testing, and 
documentation that updates itself.

Every design decision in this project mirrors what an analytics engineer would do 
on the job.

---

## How the Pipeline Works

I organized the transformation logic into three layers. Each layer has a specific 
job and nothing else.

**Staging** — I clean the raw CSV data here. Rename columns to be consistent, 
cast dates from text to timestamps, remove ambiguity. No business logic, no joins. 
Just clean data. One model per source table.

**Intermediate** — This is where I join tables and apply business rules. I built 
two models here. The first enriches every order with customer info, payment totals, 
review scores and delivery metrics. The second aggregates all order activity to 
the seller level. These models exist so the mart layer stays simple and readable.

**Marts** — Three final tables that a BI tool or analyst can query directly. 
One for order performance, one for seller performance, one for customer behavior. 
These are materialized as physical tables so queries are fast.

---

## Models

### Staging (8 views)
| Model | What it does |
|-------|-------------|
| stg_orders | Cleans order timestamps and standardizes status values |
| stg_customers | Customer city and state with clean column names |
| stg_order_items | Line items with price and freight per order |
| stg_order_payments | Payment type, installments and value per order |
| stg_order_reviews | Review scores and timestamps |
| stg_products | Product dimensions and category in Portuguese |
| stg_sellers | Seller location data |
| stg_category_translations | Maps Portuguese category names to English |

### Intermediate (2 views)
| Model | What it does |
|-------|-------------|
| int_orders_enriched | Joins orders, customers, items, payments and reviews into one row per order. Calculates delivery days and days early or late vs estimated date |
| int_seller_metrics | Aggregates all order activity to one row per seller with revenue, review scores and cancellation counts |

### Marts (3 tables)
| Model | What it does |
|-------|-------------|
| mart_order_performance | Adds delivery status (On Time / Late / Canceled) and review sentiment (Positive / Neutral / Negative) flags to every order |
| mart_seller_performance | Scores every seller as Top, Average, or Underperforming based on review score and cancellation rate |
| mart_customer_behavior | Segments every customer as One Time, Repeat, or Loyal based on how many orders they placed |

---

## Testing

I wrote 17 data tests across the pipeline. Every primary key is tested for 
uniqueness and nulls. Order status is validated against an accepted values list 
so the pipeline breaks loudly if an unexpected value appears in the source data 
rather than silently passing bad data downstream.

This is the part of analytics engineering most people skip in portfolio projects. 
I didn't skip it because in a real job, untested pipelines are liabilities.

---

## How to Run It Yourself
```bash
# Install dbt with DuckDB adapter
pip install dbt-duckdb

# Load the raw CSVs into DuckDB
dbt seed

# Run all 11 models
dbt run

# Run all 17 tests
dbt test

# Generate and view documentation
dbt docs generate
dbt docs serve
```

---

## What I Learned

Setting up the layered architecture forced me to think clearly about separation 
of concerns what belongs in staging vs intermediate vs marts. That clarity 
makes the pipeline easier to debug, easier to extend, and easier for another 
analyst to pick up and understand.

The part that surprised me most was how much dbt's dependency tracking changes 
the way you think about SQL. When you use ref() instead of hardcoding table names, 
you stop thinking in individual queries and start thinking in data flows. That 
shift is what analytics engineering actually is.

---

**Dataset:** Olist Brazilian E-Commerce — Kaggle  
**Tools:** dbt Core 1.11, DuckDB, SQL  
**Models:** 11 | **Tests:** 17 | **Seeds:** 9
```

Save this into your README.md, then run:
```
git add README.md
git commit -m "Add README"
git push
