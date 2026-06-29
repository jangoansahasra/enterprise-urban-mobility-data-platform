# Machine Learning Modeling

## Overview

This project includes a machine learning layer for predicting NYC yellow taxi trip duration.

The first model predicts:

```text
trip_duration_minutes
```

The model is trained from the PostgreSQL analytics view:

```text
vw_ml_trip_features
```

This demonstrates that the ML workflow uses the cleaned and database-ready analytics layer rather than directly training from raw files.

## Training Data Source

Training data is loaded from PostgreSQL using SQLAlchemy.

Source view:

```sql
vw_ml_trip_features
```

The view joins trip facts with pickup and dropoff location dimensions and exposes ML-ready fields.

## Target Variable

```text
trip_duration_minutes
```

This value is calculated during the transformation step using pickup and dropoff timestamps.

## Features

The first model uses:

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

## Model

The initial model is a scikit-learn `RandomForestRegressor`.

The training pipeline includes:

- median imputation for numeric features
- most-frequent imputation for categorical features
- standard scaling for numeric features
- one-hot encoding for categorical features
- random forest regression model

## Training Sample

The first version trains on a sample of:

```text
250,000 rows
```

This keeps training practical on a laptop while still using a large real-world sample.

## Evaluation Metrics

Initial model performance:

```text
MAE:  1.35 minutes
RMSE: 3.40 minutes
R2:   0.9129
```

Metrics are saved to:

```text
ml/models/trip_duration_metrics.json
```

## Feature Importance

Feature importance is exported to:

```text
ml/models/trip_duration_feature_importance.csv
```

Top features from the first model:

```text
fare_amount
trip_distance
pickup_hour
total_amount
pickup_borough
```

## Interpretation

The model predicts trip duration with an average error of about 1.35 minutes on the test split.

The strong R2 score is expected because fare and total amount are highly related to trip distance and duration.

## Limitation

This model includes `fare_amount` and `total_amount`, which may only be known after a trip is completed.

That makes this model useful for analytical modeling and operational analysis, but less realistic for pre-trip prediction.

A future production-style model should exclude post-trip fields such as:

```text
fare_amount
total_amount
tip_amount
```

and use only features known before or at pickup time.

## Run Training

```bash
python ml/train_model.py
```

This creates a local model artifact:

```text
ml/models/trip_duration_model.joblib
```

Generated model artifacts are ignored by Git and can be recreated by running the training script.

## Run Prediction

```bash
python ml/predict.py
```

Example output:

```text
Predicted trip duration: 21.57 minutes
```

## API Prediction Endpoint

The trained model is exposed through FastAPI:

```text
POST /predict/trip-duration
```

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

## Future Improvements

Potential improvements include:

- train a pre-trip prediction model without fare or total amount
- compare Linear Regression, Random Forest, and XGBoost
- log experiment results
- expose feature importance through documentation or dashboards
- add model monitoring for prediction drift