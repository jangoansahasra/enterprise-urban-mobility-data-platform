# Data Dictionary

## Overview

This data dictionary documents the main tables, fields, and derived columns used in the Enterprise Urban Mobility Data Platform.

The platform uses NYC Yellow Taxi trip records and a taxi zone lookup table to create analytics-ready and machine-learning-ready datasets.

## Database Tables

The PostgreSQL database contains the following core tables:

```text
dim_vendor
dim_payment_type
dim_location
fact_trips
```

## dim_vendor

Reference table for taxi technology vendors.

| Column | Description |
|---|---|
| `vendor_id` | Vendor identifier from the TLC trip data |
| `vendor_name` | Human-readable vendor name |

Example values:

| vendor_id | vendor_name |
|---:|---|
| 1 | Creative Mobile Technologies |
| 2 | VeriFone Inc. |

## dim_payment_type

Reference table for payment type codes.

| Column | Description |
|---|---|
| `payment_type_id` | TLC payment type code |
| `payment_type_name` | Human-readable payment type |

Example values:

| payment_type_id | payment_type_name |
|---:|---|
| 0 | Unknown / missing |
| 1 | Credit card |
| 2 | Cash |
| 3 | No charge |
| 4 | Dispute |
| 5 | Unknown |
| 6 | Voided trip |

## dim_location

Reference table for taxi zones.

| Column | Description |
|---|---|
| `location_id` | TLC taxi zone location ID |
| `borough` | NYC borough or area name |
| `zone` | Taxi zone name |
| `service_zone` | TLC service zone category |

This table is loaded from:

```text
data/raw/taxi_zone_lookup.csv
```

## fact_trips

Main fact table containing cleaned taxi trip records.

| Column | Description |
|---|---|
| `trip_id` | Surrogate primary key generated in PostgreSQL |
| `vendor_id` | Vendor identifier, references `dim_vendor` |
| `payment_type_id` | Payment type identifier, references `dim_payment_type` |
| `pickup_location_id` | Pickup location ID, references `dim_location` |
| `dropoff_location_id` | Dropoff location ID, references `dim_location` |
| `pickup_datetime` | Trip pickup timestamp |
| `dropoff_datetime` | Trip dropoff timestamp |
| `passenger_count` | Number of passengers reported for the trip |
| `trip_distance` | Trip distance in miles |
| `ratecode_id` | TLC rate code identifier |
| `store_and_fwd_flag` | Store-and-forward trip flag |
| `fare_amount` | Base fare amount |
| `extra` | Extra charges |
| `mta_tax` | MTA tax amount |
| `tip_amount` | Tip amount |
| `tolls_amount` | Toll amount |
| `improvement_surcharge` | Improvement surcharge |
| `total_amount` | Total charged amount |
| `congestion_surcharge` | Congestion surcharge |
| `airport_fee` | Airport fee |
| `cbd_congestion_fee` | Central Business District congestion fee when available |
| `trip_duration_minutes` | Derived trip duration in minutes |
| `pickup_date` | Date portion of pickup timestamp |
| `pickup_hour` | Hour of day when trip started |
| `pickup_day_of_week` | Day name of pickup timestamp |
| `pickup_month` | Month number of pickup timestamp |
| `is_weekend` | Boolean flag for Saturday or Sunday pickup |
| `fare_per_mile` | Derived fare amount divided by trip distance |
| `tip_percentage` | Derived tip amount divided by fare amount |

## Derived Fields

### trip_duration_minutes

Calculated as:

```text
dropoff_datetime - pickup_datetime
```

Converted to minutes.

Used for:

- trip duration analysis
- ML target variable
- outlier detection

### pickup_date

Extracted from `pickup_datetime`.

Used for:

- daily trip summaries
- date-level trend analysis
- dashboard filtering

### pickup_hour

Extracted from `pickup_datetime`.

Used for:

- demand by hour
- peak travel period analysis
- ML features

### pickup_day_of_week

Day name extracted from `pickup_datetime`.

Used for:

- weekday/weekend analysis
- trip pattern analysis
- ML features

### pickup_month

Month number extracted from `pickup_datetime`.

Used for:

- monthly aggregation
- seasonal trend analysis
- ML features

### is_weekend

Boolean derived from pickup day.

```text
true = Saturday or Sunday
false = Monday through Friday
```

Used for:

- weekend vs weekday comparison
- ML features

### fare_per_mile

Calculated as:

```text
fare_amount / trip_distance
```

Used for:

- pricing analysis
- zone performance analysis
- suspicious fare pattern checks

### tip_percentage

Calculated as:

```text
tip_amount / fare_amount * 100
```

Used for:

- tipping behavior analysis
- payment and revenue analysis

## Analytics Views

The project creates the following SQL analytics views:

| View | Purpose |
|---|---|
| `vw_daily_trip_summary` | Daily trip, revenue, fare, distance, duration, and tip metrics |
| `vw_hourly_demand` | Trip demand and revenue by pickup hour |
| `vw_borough_revenue` | Revenue and trip metrics by pickup/dropoff borough pair |
| `vw_zone_performance` | Pickup zone-level demand and revenue performance |
| `vw_payment_summary` | Trip and revenue metrics by payment type |
| `vw_ml_trip_features` | ML-ready feature view for trip duration modeling |

## ML Feature Fields

The machine learning models use features from:

```text
vw_ml_trip_features
```

### Analytical Model Features

The analytical model uses:

```text
pickup_hour
pickup_day_of_week
pickup_month
is_weekend
passenger_count
trip_distance
fare_amount
total_amount
pickup_borough
dropoff_borough
payment_type_id
```

This model includes post-trip financial fields and is useful for analytical modeling.

### Pre-Trip Model Features

The pre-trip model uses:

```text
pickup_hour
pickup_day_of_week
pickup_month
is_weekend
passenger_count
trip_distance
pickup_borough
dropoff_borough
payment_type_id
```

This model excludes post-trip financial fields such as:

```text
fare_amount
total_amount
tip_amount
```

This makes the model more realistic for prediction before or at pickup time.

## Data Quality Notes

The cleaned dataset filters out critical invalid records, including:

- missing pickup/dropoff timestamps
- dropoff timestamp before pickup timestamp
- non-positive trip distance
- non-positive fare amount
- negative total amount
- missing pickup/dropoff location IDs
- pickup/dropoff location IDs not found in the taxi zone lookup table
- extreme invalid date records outside the selected processing window

Known remaining notes:

- some trips have missing passenger count
- some extreme but valid trips remain for analytical transparency
- TLC monthly files may include a small number of records near month boundaries

## Grain

The grain of `fact_trips` is:

```text
one row per cleaned taxi trip
```

Each row represents a single completed yellow taxi trip after validation, transformation, and enrichment.