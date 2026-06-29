# API Documentation

## Overview

The FastAPI layer exposes analytics and machine learning predictions from the Enterprise Urban Mobility Data Platform.

The API reads from PostgreSQL analytics views, fact/dimension tables, and a trained machine learning model built from cleaned NYC Yellow Taxi trip data.

## Run Locally

Start PostgreSQL with Docker Compose:

```bash
docker compose up -d
```

Run the API:

```bash
python -m uvicorn api.main:app --reload
```

Interactive API docs are available at:

```text
http://127.0.0.1:8000/docs
```

## Environment Variables

The API uses the following environment variables:

```text
DB_HOST=localhost
DB_PORT=5433
DB_NAME=urban_mobility_db
DB_USER=urban_user
DB_PASSWORD=urban_password
```

These should be stored locally in `.env`.

## Endpoints

### GET /

Returns a welcome message.

Example response:

```json
{
  "message": "Enterprise Urban Mobility Data Platform API",
  "docs": "/docs"
}
```

### GET /health

Checks API and database connectivity.

Example response:

```json
{
  "status": "healthy",
  "database": "connected"
}
```

### GET /analytics/trips/summary

Returns executive summary metrics.

Example response:

```json
{
  "total_trips": 10413054,
  "total_revenue": "283836767.29",
  "avg_fare_amount": "18.52",
  "avg_trip_distance": "5.83",
  "avg_trip_duration_minutes": "15.60",
  "avg_tip_percentage": "19.08"
}
```

### GET /analytics/revenue/by-borough

Returns top pickup-to-dropoff borough revenue patterns.

Query parameters:

```text
limit: integer, default 10, min 1, max 100
```

Example:

```bash
curl "http://127.0.0.1:8000/analytics/revenue/by-borough?limit=5"
```

### GET /analytics/demand/by-hour

Returns trip demand by pickup hour.

Example:

```bash
curl "http://127.0.0.1:8000/analytics/demand/by-hour"
```

### GET /analytics/zones/top-pickups

Returns top pickup zones by trip volume.

Query parameters:

```text
limit: integer, default 10, min 1, max 100
```

Example:

```bash
curl "http://127.0.0.1:8000/analytics/zones/top-pickups?limit=5"
```

### GET /analytics/payments/summary

Returns payment type summary metrics.

Example:

```bash
curl "http://127.0.0.1:8000/analytics/payments/summary"
```

### POST /predict/trip-duration

Predicts taxi trip duration in minutes using the trained machine learning model.

The endpoint expects trip features as JSON and returns a predicted duration.

Example request:

```bash
curl -X POST "http://127.0.0.1:8000/predict/trip-duration" \
  -H "Content-Type: application/json" \
  -d '{
    "pickup_hour": 14,
    "pickup_day_of_week": "Wednesday",
    "pickup_month": 1,
    "is_weekend": false,
    "passenger_count": 1,
    "trip_distance": 3.2,
    "fare_amount": 18.5,
    "total_amount": 24.3,
    "pickup_borough": "Manhattan",
    "dropoff_borough": "Manhattan",
    "payment_type_id": 1
  }'
```

Example response:

```json
{
  "predicted_trip_duration_minutes": 21.57
}
```

Note: this first model includes fare and total amount, so it is best interpreted as an analytical trip-duration model. A future pre-trip prediction model should exclude post-trip values such as fare, total amount, and tip amount.

## Notes

Numeric values from PostgreSQL `NUMERIC` fields may be serialized as strings in JSON responses. This preserves exact decimal precision for revenue, fare, distance, and percentage metrics.

The prediction endpoint requires the local trained model artifact:

```text
ml/models/trip_duration_model.joblib
```

If the model file does not exist locally, run:

```bash
python ml/train_model.py
```