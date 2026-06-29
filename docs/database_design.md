# Database Design

## Overview

The PostgreSQL database is the analytical storage layer for the Enterprise Urban Mobility Data Platform.

It stores cleaned NYC Yellow Taxi trip data in a structured format that supports:

- SQL analytics
- BI/dashboard reporting
- FastAPI endpoints
- machine learning feature generation
- data quality validation

The database is designed using a simple fact and dimension model.

## Database Name

```text
urban_mobility_db
```

## Core Tables

The database contains four core tables:

```text
dim_vendor
dim_payment_type
dim_location
fact_trips
```

## Why Fact and Dimension Tables?

The project uses a fact and dimension structure because taxi trip data has a natural analytical shape.

The trip itself is the measurable business event. Each trip has measures such as:

- fare amount
- total amount
- tip amount
- trip distance
- trip duration
- passenger count

These belong in the fact table.

Descriptive lookup information, such as vendor names, payment type names, and location names, belongs in dimension tables.

This structure makes the database easier to query, easier to validate, and easier to use for BI dashboards.

## fact_trips

`fact_trips` is the main table in the database.

Grain:

```text
one row per cleaned taxi trip
```

This table stores trip-level facts and derived metrics.

Important columns include:

| Column | Purpose |
|---|---|
| `trip_id` | Surrogate primary key |
| `vendor_id` | Foreign key to `dim_vendor` |
| `payment_type_id` | Foreign key to `dim_payment_type` |
| `pickup_location_id` | Foreign key to `dim_location` |
| `dropoff_location_id` | Foreign key to `dim_location` |
| `pickup_datetime` | Trip start timestamp |
| `dropoff_datetime` | Trip end timestamp |
| `trip_distance` | Trip distance in miles |
| `fare_amount` | Base fare amount |
| `total_amount` | Total charged amount |
| `tip_amount` | Tip amount |
| `trip_duration_minutes` | Derived duration metric |
| `pickup_hour` | Derived pickup hour |
| `pickup_day_of_week` | Derived pickup weekday |
| `pickup_month` | Derived pickup month |
| `is_weekend` | Weekend flag |
| `fare_per_mile` | Derived fare efficiency metric |
| `tip_percentage` | Derived tip behavior metric |

## dim_location

`dim_location` stores taxi zone lookup data.

Source file:

```text
data/raw/taxi_zone_lookup.csv
```

Important columns:

| Column | Purpose |
|---|---|
| `location_id` | TLC location identifier |
| `borough` | Borough or area name |
| `zone` | Taxi zone name |
| `service_zone` | TLC service zone category |

This dimension allows trip records to be analyzed by pickup and dropoff geography.

## dim_vendor

`dim_vendor` stores taxi vendor reference data.

Important columns:

| Column | Purpose |
|---|---|
| `vendor_id` | TLC vendor identifier |
| `vendor_name` | Human-readable vendor name |

This dimension makes vendor IDs more readable in downstream analysis.

## dim_payment_type

`dim_payment_type` stores payment type reference data.

Important columns:

| Column | Purpose |
|---|---|
| `payment_type_id` | TLC payment code |
| `payment_type_name` | Human-readable payment type |

The table includes `0` as an unknown or missing payment type value because some cleaned records contain missing or non-standard payment codes.

## Table Relationships

The fact table connects to the dimension tables using foreign keys.

```text
fact_trips.vendor_id
        → dim_vendor.vendor_id

fact_trips.payment_type_id
        → dim_payment_type.payment_type_id

fact_trips.pickup_location_id
        → dim_location.location_id

fact_trips.dropoff_location_id
        → dim_location.location_id
```

This allows one trip table to join to the location dimension twice: once for pickup geography and once for dropoff geography.

## Schema Files

Database schema files are stored in:

```text
database/
├── schema.sql
├── indexes.sql
└── seed_reference_tables.sql
```

Purpose:

| File | Purpose |
|---|---|
| `schema.sql` | Creates core fact and dimension tables |
| `seed_reference_tables.sql` | Inserts vendor and payment type reference values |
| `indexes.sql` | Adds indexes for common query patterns |

## Indexing Strategy

Indexes are added to improve common query patterns.

The project indexes fields commonly used for:

- joins
- date filtering
- hourly analysis
- location analysis
- payment analysis

Common indexed fields include:

```text
pickup_datetime
pickup_date
pickup_hour
pickup_location_id
dropoff_location_id
payment_type_id
vendor_id
```

These indexes help support analytics views and API queries.

## Analytics Views

The SQL analytics layer creates business-ready views on top of the fact and dimension tables.

Views:

```text
vw_daily_trip_summary
vw_hourly_demand
vw_borough_revenue
vw_zone_performance
vw_payment_summary
vw_ml_trip_features
```

Purpose:

| View | Purpose |
|---|---|
| `vw_daily_trip_summary` | Daily trip and revenue trends |
| `vw_hourly_demand` | Trip demand by pickup hour |
| `vw_borough_revenue` | Revenue by pickup/dropoff borough pair |
| `vw_zone_performance` | Pickup zone performance metrics |
| `vw_payment_summary` | Metrics by payment type |
| `vw_ml_trip_features` | Feature set for ML training |

## Why Use SQL Views?

SQL views provide a stable analytics layer between the raw database tables and downstream consumers.

They are useful because:

- API endpoints can query simple views instead of complex SQL joins
- dashboard tools can connect to business-ready datasets
- machine learning scripts can train from consistent feature definitions
- analytical logic is centralized in SQL
- future changes can be made in views without changing every consumer

## Data Quality Constraints

The database design supports quality through:

- primary keys
- foreign keys
- typed columns
- reference tables
- SQL validation checks

The ETL transformation filters critical invalid records before loading into PostgreSQL.

After loading, `sql/data_quality_checks.sql` verifies:

- row counts
- required null checks
- invalid business rule counts
- foreign key match checks
- duplicate-like record checks
- outlier counts
- date ranges
- missing passenger count percentages

## Load Strategy

Cleaned trip data is loaded from:

```text
data/processed/cleaned_taxi_trips_2025_q1.parquet
```

into PostgreSQL using:

```text
etl/load/load_to_postgres.py
```

The loader supports:

- sample loading for fast local testing
- full loading for complete analysis
- bulk loading with PostgreSQL COPY for better performance

Sample load:

```bash
python etl/load/load_to_postgres.py
```

Full load:

```bash
LOAD_SAMPLE_SIZE=0 python etl/load/load_to_postgres.py
```

## Full Load Result

The final PostgreSQL load contains:

```text
fact_trips: 10,413,054 rows
dim_location: 265 rows
dim_vendor: 4 rows
dim_payment_type: 7 rows
```

## Downstream Consumers

The database supports three main downstream consumers.

### FastAPI

FastAPI queries SQL views and tables to return JSON analytics and prediction results.

### Power BI

Power BI can connect to PostgreSQL or exported analytics outputs to build dashboards.

### Machine Learning

ML training scripts query `vw_ml_trip_features` to train trip duration prediction models from the curated database layer.

## Design Tradeoffs

This design is intentionally simple enough to run locally, but structured enough to resemble a real enterprise analytics platform.

Tradeoffs:

- PostgreSQL is used instead of a distributed warehouse because the project runs locally
- SQL views are used instead of dbt models for simplicity
- raw files are preserved, while cleaned data is stored separately
- sample loading is supported for fast testing
- full loading is supported for complete analysis
- generated model artifacts are ignored by Git but reproducible through training scripts