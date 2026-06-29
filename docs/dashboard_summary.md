# Dashboard Summary

## Overview

The Power BI dashboard will provide executive and operational insights into NYC Yellow Taxi trip activity using the cleaned PostgreSQL data model and SQL analytics views.

The dashboard is planned as the business intelligence layer of the Enterprise Urban Mobility Data Platform.

Because Power BI Desktop is not available on macOS, dashboard development will be completed later on a Windows machine. This document defines the planned dashboard structure, metrics, visuals, and data sources.

## Dashboard Goals

The dashboard should help transportation analysts and decision-makers understand:

- overall taxi trip volume and revenue
- demand patterns by hour, day, and month
- borough and zone-level trip activity
- revenue performance by geography
- payment type behavior
- fare, tip, and distance trends
- machine learning model performance for trip duration prediction

## Data Sources

Primary database:

```text
urban_mobility_db
```

Core tables:

```text
fact_trips
dim_location
dim_vendor
dim_payment_type
```

Recommended SQL views:

```text
vw_daily_trip_summary
vw_hourly_demand
vw_borough_revenue
vw_zone_performance
vw_payment_summary
vw_ml_trip_features
```

Power BI can connect directly to PostgreSQL or use exported CSV extracts from these views.

## Page 1: Executive Overview

Purpose:

Provide a high-level summary of taxi operations and business performance.

Recommended KPIs:

- total trips
- total revenue
- average fare amount
- average total amount
- average trip distance
- average trip duration
- average tip percentage

Recommended visuals:

- KPI cards for core metrics
- line chart for daily trips
- line chart for daily revenue
- bar chart for top pickup boroughs
- bar chart for top dropoff boroughs

Recommended source views:

```text
vw_daily_trip_summary
vw_borough_revenue
```

## Page 2: Demand Analysis

Purpose:

Analyze when taxi demand is highest.

Recommended metrics:

- trips by pickup hour
- trips by day of week
- trips by month
- weekday vs weekend trips
- average trip duration by hour

Recommended visuals:

- column chart for trips by hour
- bar chart for trips by day of week
- line chart for trips over time
- stacked bar chart for weekday vs weekend demand
- heatmap-style matrix for hour and day-of-week demand

Recommended source views:

```text
vw_hourly_demand
fact_trips
```

## Page 3: Geography Analysis

Purpose:

Analyze trip activity and revenue by borough and taxi zone.

Recommended metrics:

- total trips by pickup borough
- total trips by dropoff borough
- total revenue by pickup/dropoff borough pair
- top pickup zones
- top dropoff zones
- average trip distance by borough pair

Recommended visuals:

- bar chart for top pickup zones
- bar chart for top dropoff zones
- matrix for pickup borough vs dropoff borough
- map visual using borough or zone data
- ranked table of zone performance

Recommended source views:

```text
vw_borough_revenue
vw_zone_performance
dim_location
```

## Page 4: Payment and Revenue

Purpose:

Analyze how customers pay and how payment type relates to revenue and tips.

Recommended metrics:

- trips by payment type
- revenue by payment type
- average fare by payment type
- average tip percentage by payment type
- average total amount by payment type

Recommended visuals:

- donut chart for payment type distribution
- bar chart for revenue by payment type
- bar chart for average tip percentage by payment type
- line chart for daily revenue trend
- table of payment type summary metrics

Recommended source views:

```text
vw_payment_summary
vw_daily_trip_summary
```

## Page 5: ML Insights

Purpose:

Summarize machine learning results and trip duration prediction behavior.

Recommended metrics:

- analytical model MAE
- analytical model RMSE
- analytical model R2
- pre-trip model MAE
- pre-trip model RMSE
- pre-trip model R2
- top model features by importance

Recommended visuals:

- KPI cards for model metrics
- bar chart for analytical model feature importance
- bar chart for pre-trip model feature importance
- comparison table between analytical and pre-trip models
- scatter plot for predicted vs actual duration if prediction outputs are exported later

Recommended files:

```text
ml/models/trip_duration_metrics.json
ml/models/trip_duration_feature_importance.csv
ml/models/pretrip_duration_metrics.json
ml/models/pretrip_duration_feature_importance.csv
```

## Suggested Dashboard Filters

Recommended slicers:

- pickup date
- pickup month
- pickup day of week
- pickup hour
- pickup borough
- dropoff borough
- payment type
- vendor

These filters should allow users to explore trip patterns by time, location, and payment behavior.

## Design Notes

The dashboard should be designed for operational analytics rather than marketing presentation.

Recommended style:

- clear KPI cards
- consistent color palette
- readable labels
- restrained visual design
- simple navigation between pages
- visuals focused on comparison, trends, and geographic patterns
- avoid cluttered pages with too many charts

## Expected Business Insights

The dashboard should help answer questions such as:

- which zones generate the most taxi demand
- which borough pairs produce the most revenue
- what hours have the highest trip activity
- how weekend demand differs from weekday demand
- which payment types are most common
- where average trip duration is highest
- how well the ML models estimate trip duration

## Future Dashboard Enhancements

Potential future improvements:

- connect Power BI directly to PostgreSQL
- publish dashboard screenshots to the GitHub README
- add a dashboard usage guide
- add route-level or zone-pair flow analysis
- add weather or holiday filters
- add drill-through pages for zone-level analysis
- add model prediction error visuals
- add confidence intervals for aggregate analytics such as average fare, average duration, and revenue trends
- add prediction intervals for trip duration predictions to show uncertainty around model outputs