CREATE INDEX IF NOT EXISTS idx_fact_trips_pickup_datetime
    ON fact_trips(pickup_datetime);

CREATE INDEX IF NOT EXISTS idx_fact_trips_pickup_date
    ON fact_trips(pickup_date);

CREATE INDEX IF NOT EXISTS idx_fact_trips_pickup_hour
    ON fact_trips(pickup_hour);

CREATE INDEX IF NOT EXISTS idx_fact_trips_vendor_id
    ON fact_trips(vendor_id);

CREATE INDEX IF NOT EXISTS idx_fact_trips_payment_type_id
    ON fact_trips(payment_type_id);

CREATE INDEX IF NOT EXISTS idx_fact_trips_pickup_location_id
    ON fact_trips(pickup_location_id);

CREATE INDEX IF NOT EXISTS idx_fact_trips_dropoff_location_id
    ON fact_trips(dropoff_location_id);

CREATE INDEX IF NOT EXISTS idx_fact_trips_pickup_month
    ON fact_trips(pickup_month);