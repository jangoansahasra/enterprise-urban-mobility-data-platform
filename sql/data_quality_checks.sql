-- Row counts by core table
SELECT
    'dim_location' AS table_name,
    COUNT(*) AS row_count
FROM dim_location
UNION ALL
SELECT
    'dim_vendor' AS table_name,
    COUNT(*) AS row_count
FROM dim_vendor
UNION ALL
SELECT
    'dim_payment_type' AS table_name,
    COUNT(*) AS row_count
FROM dim_payment_type
UNION ALL
SELECT
    'fact_trips' AS table_name,
    COUNT(*) AS row_count
FROM fact_trips;


-- Null checks for required fact table fields
SELECT
    COUNT(*) AS null_required_field_count
FROM fact_trips
WHERE pickup_datetime IS NULL
   OR dropoff_datetime IS NULL
   OR pickup_location_id IS NULL
   OR dropoff_location_id IS NULL
   OR trip_distance IS NULL
   OR fare_amount IS NULL
   OR total_amount IS NULL;


-- Business rule checks
SELECT
    SUM(CASE WHEN dropoff_datetime < pickup_datetime THEN 1 ELSE 0 END) AS dropoff_before_pickup_count,
    SUM(CASE WHEN trip_distance <= 0 THEN 1 ELSE 0 END) AS non_positive_trip_distance_count,
    SUM(CASE WHEN fare_amount <= 0 THEN 1 ELSE 0 END) AS non_positive_fare_amount_count,
    SUM(CASE WHEN total_amount < 0 THEN 1 ELSE 0 END) AS negative_total_amount_count,
    SUM(CASE WHEN trip_duration_minutes < 0 THEN 1 ELSE 0 END) AS negative_trip_duration_count
FROM fact_trips;


-- Foreign key coverage checks
SELECT
    COUNT(*) AS missing_pickup_location_matches
FROM fact_trips
LEFT JOIN dim_location
    ON fact_trips.pickup_location_id = dim_location.location_id
WHERE dim_location.location_id IS NULL;


SELECT
    COUNT(*) AS missing_dropoff_location_matches
FROM fact_trips
LEFT JOIN dim_location
    ON fact_trips.dropoff_location_id = dim_location.location_id
WHERE dim_location.location_id IS NULL;


SELECT
    COUNT(*) AS missing_payment_type_matches
FROM fact_trips
LEFT JOIN dim_payment_type
    ON fact_trips.payment_type_id = dim_payment_type.payment_type_id
WHERE fact_trips.payment_type_id IS NOT NULL
  AND dim_payment_type.payment_type_id IS NULL;


-- Duplicate-like trip check using operational fields
SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    pickup_location_id,
    dropoff_location_id,
    passenger_count,
    trip_distance,
    fare_amount,
    COUNT(*) AS duplicate_like_count
FROM fact_trips
GROUP BY
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    pickup_location_id,
    dropoff_location_id,
    passenger_count,
    trip_distance,
    fare_amount
HAVING COUNT(*) > 1
ORDER BY duplicate_like_count DESC
LIMIT 20;


-- Outlier checks
SELECT
    SUM(CASE WHEN trip_duration_minutes > 360 THEN 1 ELSE 0 END) AS trips_over_6_hours,
    SUM(CASE WHEN trip_distance > 100 THEN 1 ELSE 0 END) AS trips_over_100_miles,
    SUM(CASE WHEN fare_amount > 500 THEN 1 ELSE 0 END) AS fares_over_500
FROM fact_trips;


-- Date range check
SELECT
    MIN(pickup_datetime) AS min_pickup_datetime,
    MAX(pickup_datetime) AS max_pickup_datetime,
    MIN(dropoff_datetime) AS min_dropoff_datetime,
    MAX(dropoff_datetime) AS max_dropoff_datetime
FROM fact_trips;


-- Passenger count completeness
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END) AS missing_passenger_count,
    ROUND(
        100.0 * SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_passenger_count_percentage
FROM fact_trips;