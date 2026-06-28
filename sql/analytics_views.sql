CREATE OR REPLACE VIEW vw_daily_trip_summary AS
SELECT
    pickup_date,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare_amount,
    ROUND(AVG(total_amount), 2) AS avg_total_amount,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes,
    ROUND(AVG(tip_percentage), 2) AS avg_tip_percentage
FROM fact_trips
GROUP BY pickup_date;


CREATE OR REPLACE VIEW vw_hourly_demand AS
SELECT
    pickup_hour,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM fact_trips
GROUP BY pickup_hour;


CREATE OR REPLACE VIEW vw_borough_revenue AS
SELECT
    pickup_location.borough AS pickup_borough,
    dropoff_location.borough AS dropoff_borough,
    COUNT(*) AS total_trips,
    ROUND(SUM(fact_trips.total_amount), 2) AS total_revenue,
    ROUND(AVG(fact_trips.total_amount), 2) AS avg_total_amount,
    ROUND(AVG(fact_trips.trip_distance), 2) AS avg_trip_distance
FROM fact_trips
JOIN dim_location AS pickup_location
    ON fact_trips.pickup_location_id = pickup_location.location_id
JOIN dim_location AS dropoff_location
    ON fact_trips.dropoff_location_id = dropoff_location.location_id
GROUP BY
    pickup_location.borough,
    dropoff_location.borough;


CREATE OR REPLACE VIEW vw_zone_performance AS
SELECT
    pickup_location.borough AS pickup_borough,
    pickup_location.zone AS pickup_zone,
    COUNT(*) AS pickup_trips,
    ROUND(SUM(fact_trips.total_amount), 2) AS total_revenue,
    ROUND(AVG(fact_trips.total_amount), 2) AS avg_total_amount,
    ROUND(AVG(fact_trips.trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(fact_trips.trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM fact_trips
JOIN dim_location AS pickup_location
    ON fact_trips.pickup_location_id = pickup_location.location_id
GROUP BY
    pickup_location.borough,
    pickup_location.zone;


CREATE OR REPLACE VIEW vw_payment_summary AS
SELECT
    dim_payment_type.payment_type_name,
    COUNT(*) AS total_trips,
    ROUND(SUM(fact_trips.total_amount), 2) AS total_revenue,
    ROUND(AVG(fact_trips.tip_amount), 2) AS avg_tip_amount,
    ROUND(AVG(fact_trips.tip_percentage), 2) AS avg_tip_percentage
FROM fact_trips
LEFT JOIN dim_payment_type
    ON fact_trips.payment_type_id = dim_payment_type.payment_type_id
GROUP BY dim_payment_type.payment_type_name;


CREATE OR REPLACE VIEW vw_ml_trip_features AS
SELECT
    trip_id,
    pickup_hour,
    pickup_day_of_week,
    pickup_month,
    is_weekend,
    passenger_count,
    trip_distance,
    fare_amount,
    total_amount,
    pickup_location.borough AS pickup_borough,
    dropoff_location.borough AS dropoff_borough,
    payment_type_id,
    trip_duration_minutes
FROM fact_trips
JOIN dim_location AS pickup_location
    ON fact_trips.pickup_location_id = pickup_location.location_id
JOIN dim_location AS dropoff_location
    ON fact_trips.dropoff_location_id = dropoff_location.location_id
WHERE trip_duration_minutes IS NOT NULL
  AND trip_duration_minutes > 0;