import argparse
import logging
from pathlib import Path

from etl.load.load_to_postgres import main as run_postgres_load
from etl.profile.profile_raw_data import main as run_profiling
from etl.transform.transform_taxi_data import main as run_transformation
from etl.validate.validate_taxi_data import main as run_validation


PROJECT_ROOT = Path(__file__).resolve().parents[1]
LOG_DIR = PROJECT_ROOT / "logs"
LOG_PATH = LOG_DIR / "etl_pipeline.log"


def configure_logging() -> None:
    """Configure console and file logging for the ETL pipeline."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s",
        handlers=[
            logging.FileHandler(LOG_PATH),
            logging.StreamHandler(),
        ],
    )


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Run the Enterprise Urban Mobility ETL pipeline."
    )
    parser.add_argument(
        "--load",
        action="store_true",
        help="Load transformed taxi data into PostgreSQL after transformation.",
    )
    return parser.parse_args()


def run_pipeline(load_to_postgres: bool = False) -> None:
    """Run the raw data profiling, validation, transformation, and optional load workflow."""
    logging.info("Starting Enterprise Urban Mobility ETL pipeline.")

    logging.info("Step 1: Running raw data profiling.")
    run_profiling()

    logging.info("Step 2: Running taxi data validation.")
    run_validation()

    logging.info("Step 3: Running taxi data transformation.")
    run_transformation()

    if load_to_postgres:
        logging.info("Step 4: Loading transformed data into PostgreSQL.")
        run_postgres_load()

    logging.info("ETL pipeline completed successfully.")


def main() -> None:
    """Configure logging and run the ETL pipeline."""
    configure_logging()
    args = parse_args()
    run_pipeline(load_to_postgres=args.load)


if __name__ == "__main__":
    main()