CREATE TABLE IF NOT EXISTS dim_vendor (
    vendor_id INTEGER PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_payment_type (
    payment_type_id INTEGER PRIMARY KEY,
    payment_type_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_location (
    location_id INTEGER PRIMARY KEY,
    borough VARCHAR(100),
    zone VARCHAR(150),
    service_zone VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS fact_trips (
    trip_id BIGSERIAL PRIMARY KEY,

    vendor_id INTEGER,
    payment_type_id INTEGER,
    pickup_location_id INTEGER NOT NULL,
    dropoff_location_id INTEGER NOT NULL,

    pickup_datetime TIMESTAMP NOT NULL,
    dropoff_datetime TIMESTAMP NOT NULL,

    passenger_count NUMERIC(5, 2),
    trip_distance NUMERIC(10, 2) NOT NULL,
    ratecode_id NUMERIC(5, 2),
    store_and_fwd_flag VARCHAR(5),

    fare_amount NUMERIC(10, 2) NOT NULL,
    extra NUMERIC(10, 2),
    mta_tax NUMERIC(10, 2),
    tip_amount NUMERIC(10, 2),
    tolls_amount NUMERIC(10, 2),
    improvement_surcharge NUMERIC(10, 2),
    total_amount NUMERIC(10, 2) NOT NULL,
    congestion_surcharge NUMERIC(10, 2),
    airport_fee NUMERIC(10, 2),
    cbd_congestion_fee NUMERIC(10, 2),

    trip_duration_minutes NUMERIC(10, 2),
    pickup_date DATE,
    pickup_hour INTEGER,
    pickup_day_of_week VARCHAR(20),
    pickup_month INTEGER,
    is_weekend BOOLEAN,

    fare_per_mile NUMERIC(10, 2),
    tip_percentage NUMERIC(10, 2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fact_trips_vendor
        FOREIGN KEY (vendor_id)
        REFERENCES dim_vendor(vendor_id),

    CONSTRAINT fk_fact_trips_payment_type
        FOREIGN KEY (payment_type_id)
        REFERENCES dim_payment_type(payment_type_id),

    CONSTRAINT fk_fact_trips_pickup_location
        FOREIGN KEY (pickup_location_id)
        REFERENCES dim_location(location_id),

    CONSTRAINT fk_fact_trips_dropoff_location
        FOREIGN KEY (dropoff_location_id)
        REFERENCES dim_location(location_id),

    CONSTRAINT chk_trip_distance_positive
        CHECK (trip_distance > 0),

    CONSTRAINT chk_fare_amount_positive
        CHECK (fare_amount > 0),

    CONSTRAINT chk_total_amount_non_negative
        CHECK (total_amount >= 0),

    CONSTRAINT chk_trip_duration_non_negative
        CHECK (trip_duration_minutes >= 0)
);