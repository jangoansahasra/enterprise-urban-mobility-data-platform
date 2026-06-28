-- Executive overview metrics
SELECT
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare_amount,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes,
    ROUND(AVG(tip_percentage), 2) AS avg_tip_percentage
FROM fact_trips;


-- Daily trip and revenue trend
SELECT
    pickup_date,
    total_trips,
    total_revenue,
    avg_trip_distance,
    avg_trip_duration_minutes
FROM vw_daily_trip_summary
ORDER BY pickup_date;


-- Hourly demand pattern
SELECT
    pickup_hour,
    total_trips,
    total_revenue,
    avg_trip_distance,
    avg_trip_duration_minutes
FROM vw_hourly_demand
ORDER BY pickup_hour;


-- Top pickup zones by trip volume
SELECT
    pickup_borough,
    pickup_zone,
    pickup_trips,
    total_revenue,
    avg_total_amount,
    avg_trip_distance
FROM vw_zone_performance
ORDER BY pickup_trips DESC
LIMIT 20;


-- Borough-to-borough revenue performance
SELECT
    pickup_borough,
    COALESCE(NULLIF(dropoff_borough, ''), 'Unknown') AS dropoff_borough,
    total_trips,
    total_revenue,
    avg_total_amount,
    avg_trip_distance
FROM vw_borough_revenue
ORDER BY total_revenue DESC
LIMIT 20;


-- Payment type summary
SELECT
    COALESCE(payment_type_name, 'Unknown') AS payment_type_name,
    total_trips,
    total_revenue,
    avg_tip_amount,
    avg_tip_percentage
FROM vw_payment_summary
ORDER BY total_trips DESC;


-- Weekend vs weekday demand
SELECT
    is_weekend,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM fact_trips
GROUP BY is_weekend
ORDER BY is_weekend;


-- Longest average trip duration by pickup zone
SELECT
    pickup_borough,
    pickup_zone,
    pickup_trips,
    avg_trip_duration_minutes,
    avg_trip_distance,
    total_revenue
FROM vw_zone_performance
WHERE pickup_trips >= 25
ORDER BY avg_trip_duration_minutes DESC
LIMIT 20;


-- ML feature dataset sample
SELECT
    pickup_hour,
    pickup_day_of_week,
    pickup_month,
    is_weekend,
    passenger_count,
    trip_distance,
    fare_amount,
    total_amount,
    pickup_borough,
    dropoff_borough,
    payment_type_id,
    trip_duration_minutes
FROM vw_ml_trip_features
LIMIT 100;