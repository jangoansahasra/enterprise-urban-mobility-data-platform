from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"
REPORT_DIR = PROJECT_ROOT / "data" / "validation_reports"
REPORT_PATH = REPORT_DIR / "raw_data_profile.csv"


def profile_dataframe(df: pd.DataFrame, dataset_name: str) -> list[dict]:
    """Create profiling metrics for one dataframe."""
    profile_rows = []

    profile_rows.append(
        {
            "dataset": dataset_name,
            "metric": "row_count",
            "column": None,
            "value": len(df),
        }
    )

    profile_rows.append(
        {
            "dataset": dataset_name,
            "metric": "column_count",
            "column": None,
            "value": len(df.columns),
        }
    )

    profile_rows.append(
        {
            "dataset": dataset_name,
            "metric": "duplicate_rows",
            "column": None,
            "value": int(df.duplicated().sum()),
        }
    )

    profile_rows.append(
        {
            "dataset": dataset_name,
            "metric": "memory_usage_mb",
            "column": None,
            "value": round(df.memory_usage(deep=True).sum() / (1024**2), 2),
        }
    )

    for column in df.columns:
        profile_rows.append(
            {
                "dataset": dataset_name,
                "metric": "data_type",
                "column": column,
                "value": str(df[column].dtype),
            }
        )

        profile_rows.append(
            {
                "dataset": dataset_name,
                "metric": "missing_values",
                "column": column,
                "value": int(df[column].isna().sum()),
            }
        )

        profile_rows.append(
            {
                "dataset": dataset_name,
                "metric": "missing_percentage",
                "column": column,
                "value": round(df[column].isna().mean() * 100, 2),
            }
        )

        if pd.api.types.is_numeric_dtype(df[column]):
            profile_rows.extend(
                [
                    {
                        "dataset": dataset_name,
                        "metric": "min",
                        "column": column,
                        "value": df[column].min(),
                    },
                    {
                        "dataset": dataset_name,
                        "metric": "max",
                        "column": column,
                        "value": df[column].max(),
                    },
                    {
                        "dataset": dataset_name,
                        "metric": "mean",
                        "column": column,
                        "value": round(df[column].mean(), 2),
                    },
                ]
            )

        if pd.api.types.is_datetime64_any_dtype(df[column]):
            profile_rows.extend(
                [
                    {
                        "dataset": dataset_name,
                        "metric": "min_datetime",
                        "column": column,
                        "value": df[column].min(),
                    },
                    {
                        "dataset": dataset_name,
                        "metric": "max_datetime",
                        "column": column,
                        "value": df[column].max(),
                    },
                ]
            )

    return profile_rows


def profile_taxi_files() -> list[dict]:
    """Profile all raw yellow taxi Parquet files."""
    profile_rows = []
    parquet_files = sorted(RAW_DATA_DIR.glob("yellow_tripdata_*.parquet"))

    if not parquet_files:
        raise FileNotFoundError(f"No yellow taxi Parquet files found in {RAW_DATA_DIR}")

    for parquet_file in parquet_files:
        print(f"Profiling {parquet_file.name}...")
        df = pd.read_parquet(parquet_file)
        profile_rows.extend(profile_dataframe(df, parquet_file.name))

        if {
            "tpep_pickup_datetime",
            "tpep_dropoff_datetime",
        }.issubset(df.columns):
            invalid_dropoff_count = (
                df["tpep_dropoff_datetime"] < df["tpep_pickup_datetime"]
            ).sum()

            profile_rows.append(
                {
                    "dataset": parquet_file.name,
                    "metric": "dropoff_before_pickup_count",
                    "column": None,
                    "value": int(invalid_dropoff_count),
                }
            )

        if "trip_distance" in df.columns:
            profile_rows.append(
                {
                    "dataset": parquet_file.name,
                    "metric": "non_positive_trip_distance_count",
                    "column": "trip_distance",
                    "value": int((df["trip_distance"] <= 0).sum()),
                }
            )

        if "fare_amount" in df.columns:
            profile_rows.append(
                {
                    "dataset": parquet_file.name,
                    "metric": "non_positive_fare_amount_count",
                    "column": "fare_amount",
                    "value": int((df["fare_amount"] <= 0).sum()),
                }
            )

        if "total_amount" in df.columns:
            profile_rows.append(
                {
                    "dataset": parquet_file.name,
                    "metric": "negative_total_amount_count",
                    "column": "total_amount",
                    "value": int((df["total_amount"] < 0).sum()),
                }
            )

    return profile_rows


def profile_taxi_zone_lookup() -> list[dict]:
    """Profile the taxi zone lookup CSV."""
    lookup_path = RAW_DATA_DIR / "taxi_zone_lookup.csv"

    if not lookup_path.exists():
        raise FileNotFoundError(f"Taxi zone lookup file not found: {lookup_path}")

    print(f"Profiling {lookup_path.name}...")
    df = pd.read_csv(lookup_path)
    return profile_dataframe(df, lookup_path.name)


def main() -> None:
    """Run raw data profiling and save the report."""
    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    profile_rows = []
    profile_rows.extend(profile_taxi_files())
    profile_rows.extend(profile_taxi_zone_lookup())

    report_df = pd.DataFrame(profile_rows)
    report_df.to_csv(REPORT_PATH, index=False)

    print("\nRaw data profiling complete.")
    print(f"Report saved to: {REPORT_PATH}")


if __name__ == "__main__":
    main()