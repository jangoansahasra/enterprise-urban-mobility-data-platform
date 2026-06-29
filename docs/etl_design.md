# ETL Design

## Overview

The ETL layer is responsible for converting raw NYC Yellow Taxi trip files into validated, cleaned, enriched, and database-ready datasets.

The ETL workflow follows four main stages:

```text
Profile → Validate → Transform → Load
```

This separation keeps the pipeline easier to understand, test, debug, and extend.

## ETL Folder Structure

```text
etl/
├── profile/
│   └── profile_raw_data.py
├── validate/
│   └── validate_taxi_data.py
├── transform/
│   └── transform_taxi_data.py
├── load/
│   └── load_to_postgres.py
└── pipeline.py
```

## Input Data

Raw data is stored in:

```text
data/raw/
```

Input files:

```text
yellow_tripdata_2025-01.parquet
yellow_tripdata_2025-02.parquet
yellow_tripdata_2025-03.parquet
taxi_zone_lookup.csv
```

The raw data is not modified. All cleaned and generated outputs are written to separate folders.

## Profiling Step

Script:

```text
etl/profile/profile_raw_data.py
```

Purpose:

The profiling step inspects the raw files before validation or transformation. This helps understand the structure, volume, and potential data quality issues in the source data.

Profiling checks include:

- row counts
- column counts
- column names
- data types
- missing values
- duplicate rows
- numeric summary statistics
- memory usage
- pickup and dropoff date ranges
- suspicious values such as non-positive fares or distances

Output:

```text
data/validation_reports/raw_data_profile.csv
```

Why this step matters:

Profiling gives an initial picture of the data before applying business rules. It helps identify unexpected schema changes, missing values, outliers, and source data issues.

## Validation Step

Script:

```text
etl/validate/validate_taxi_data.py
```

Purpose:

The validation step applies explicit data quality rules to the raw taxi data.

Validation rules include:

- missing pickup timestamp
- missing dropoff timestamp
- dropoff timestamp before pickup timestamp
- non-positive trip distance
- non-positive fare amount
- negative total amount
- negative passenger count
- missing passenger count
- invalid payment type
- missing pickup location ID
- missing dropoff location ID
- pickup location ID not found in taxi zone lookup
- dropoff location ID not found in taxi zone lookup
- trip duration over 6 hours
- trip distance over 100 miles
- fare amount over 500 dollars

Outputs:

```text
data/validation_reports/taxi_data_validation_summary.csv
data/validation_reports/taxi_data_invalid_records_sample.csv
```

Why this step matters:

Validation separates data quality reporting from data transformation. This makes it clear which records violate rules and allows the project to document quality issues before cleaning.

## Transformation Step

Script:

```text
etl/transform/transform_taxi_data.py
```

Purpose:

The transformation step cleans raw trip records and creates analytics-ready fields.

Main transformation tasks:

- standardize column names
- convert pickup and dropoff timestamps
- filter critical invalid records
- calculate trip duration
- extract pickup date, hour, weekday, and month
- calculate weekend flag
- calculate fare per mile
- calculate tip percentage
- join pickup zone information
- join dropoff zone information
- save cleaned output as Parquet

Derived fields:

```text
trip_duration_minutes
pickup_date
pickup_hour
pickup_day_of_week
pickup_month
is_weekend
fare_per_mile
tip_percentage
pickup_borough
pickup_zone
pickup_service_zone
dropoff_borough
dropoff_zone
dropoff_service_zone
```

Output:

```text
data/processed/cleaned_taxi_trips_2025_q1.parquet
```

Final transformed dataset:

```text
10,413,054 rows
34 columns
```

## Filtering Logic

The transformation step removes records that are not valid for analytics or database loading.

Critical filters include:

- pickup timestamp is present
- dropoff timestamp is present
- dropoff timestamp is greater than or equal to pickup timestamp
- trip distance is greater than 0
- fare amount is greater than 0
- total amount is greater than or equal to 0
- pickup location ID is present
- dropoff location ID is present
- pickup and dropoff timestamps are within the selected processing window

Date boundaries are used to remove clearly invalid records while allowing small month-boundary overlap from TLC source files.

## Load Step

Script:

```text
etl/load/load_to_postgres.py
```

Purpose:

The load step writes cleaned data into PostgreSQL.

The loader handles:

- clearing existing fact/location data before reload
- loading `dim_location`
- preparing fact table columns
- mapping missing payment types to an unknown category
- loading `fact_trips`
- supporting sample and full loads

The loader uses PostgreSQL bulk loading for better performance.

## Sample Load vs Full Load

By default, the loader uses a sample size for fast local testing:

```bash
python etl/load/load_to_postgres.py
```

Default sample:

```text
100,000 rows
```

For the full dataset:

```bash
LOAD_SAMPLE_SIZE=0 python etl/load/load_to_postgres.py
```

Full load result:

```text
10,413,054 rows loaded into fact_trips
```

Why sample loading is useful:

Sample loading allows fast development and debugging without waiting for the full dataset to load each time.

Why full loading is useful:

Full loading verifies that the pipeline works at larger scale and supports complete analytics.

## Pipeline Orchestration

Script:

```text
etl/pipeline.py
```

The pipeline runs the ETL stages in order.

Run profiling, validation, and transformation:

```bash
python -m etl.pipeline
```

Run profiling, validation, transformation, and database load:

```bash
python -m etl.pipeline --load
```

The pipeline uses logging to track progress and writes logs to:

```text
logs/etl_pipeline.log
```

## Data Quality Strategy

The ETL design handles quality in layers.

### Profiling

Identifies source data patterns and potential issues.

### Validation

Documents rule violations and generates quality reports.

### Transformation

Filters critical invalid rows and creates reliable derived fields.

### Loading

Enforces database structure, foreign keys, and expected column types.

### SQL Checks

Validates the final loaded database with SQL quality checks.

This layered approach makes the pipeline more trustworthy than transforming raw data directly without inspection.

## Outputs

Main generated outputs:

```text
data/validation_reports/raw_data_profile.csv
data/validation_reports/taxi_data_validation_summary.csv
data/validation_reports/taxi_data_invalid_records_sample.csv
data/processed/cleaned_taxi_trips_2025_q1.parquet
logs/etl_pipeline.log
```

Generated data and logs are not required to be committed because they can be recreated by running the pipeline.

## Design Decisions

### Preserve raw data

Raw files are kept unchanged so the pipeline remains reproducible and auditable.

### Separate profiling and validation

Profiling describes the data. Validation applies business rules. Keeping them separate makes the project easier to explain and maintain.

### Store cleaned data separately

Cleaned outputs are written to `data/processed/` rather than overwriting raw files.

### Use Parquet

Parquet is efficient for large analytical datasets and preserves column types better than CSV.

### Use modular scripts

Each ETL responsibility has its own module. This makes the pipeline easier to test and extend.

### Support sample loading

Sample loading speeds up local development while full loading remains available for complete analysis.

### Use database-ready transformations

The transformed data is prepared to match the PostgreSQL schema, reducing loading errors and making downstream analytics more reliable.

## Future Improvements

Potential improvements include:

- add Pytest tests for transformation functions
- add row-level rejection output for invalid records
- add schema validation with Great Expectations or Pandera
- add Airflow orchestration
- add dbt models for SQL transformations
- add automated pipeline run summaries
- add incremental loading by month