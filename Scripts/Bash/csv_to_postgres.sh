#!/bin/bash

# Script to load Parch & Posey CSVs into PostgreSQL (via docker-compose)
# Usage:
#   ./csv_to_postgres.sh             #To Append data to existing tables
#   ./csv_to_postgres.sh --reset     #To Truncate tables before loading

# Directory where this script is, regardless of where it's run from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"       


# Loading environment variables from .env so script & docker-compose stay in sync
set -a
source "$PROJECT_ROOT/.env"
set +a


# Base raw URL to download the csv files from
base_url="https://raw.githubusercontent.com/jdbarillas/parchposey/master/data-raw"

# List of CSV files to download
files=(
  accounts.csv
  orders.csv
  region.csv
  sales_reps.csv
  web_events.csv
)

# Create directory Parch_and_Posey_CSV_Files (if it doesn't exist)
echo "-----Creating Parch_and_Posey_CSV_Files Directory.....-----"
mkdir -p "$PROJECT_ROOT/Parch_and_Posey_CSV_Files"

printf "\n"  # Add one blank line

# Remove old CSVs files
echo "-----Removing Old CSV files.....-----"
rm -f "$PROJECT_ROOT/Parch_and_Posey_CSV_Files"/*.csv

printf "\n"  # Add one blank line

# Download each CSV
for f in "${files[@]}"; do
  echo "-----Downloading $f.....-----"
  curl -s -o "$PROJECT_ROOT/Parch_and_Posey_CSV_Files/$f" "$base_url/$f"
done

printf "\n"  # Add one blank line

echo "All CSVs have been downloaded into $PROJECT_ROOT/Parch_and_Posey_CSV_Files"

printf "\n"  # Add one blank line

# Directory containing CSV files
CSV_DIR="$PROJECT_ROOT/Parch_and_Posey_CSV_Files"

# Parse flag
RESET=false
if [ "$1" == "--reset" ]; then
    RESET=true
fi

# Ensure CSV directory exists
if [ ! -d "$CSV_DIR" ]; then
    echo "CSV directory $CSV_DIR does not exist. Exiting..."
    exit 1
fi

# Start services with docker-compose in detached mode
echo "Starting docker-compose services..."
docker compose -f "$PROJECT_ROOT/docker-compose.yaml" up -d

# Wait until Postgres is healthy
echo "Waiting for Postgres to be ready..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' "$POSTGRES_CONTAINER_NAME")" == "healthy" ]; do
  sleep 2
done
echo "Postgres is ready!"

# Helper to run psql inside the Postgres container
run_psql() {
    local sql="$1"
    docker exec -i "$POSTGRES_CONTAINER_NAME" \
      bash -c "PGPASSWORD=$POSTGRES_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c \"$sql\""
}

# Function to load CSV into PostgreSQL
load_csv() {
    local file_path=$1
    local file_name=$(basename "$file_path")
    local table_name=$(basename "$file_path" .csv)

    echo "Processing $file_name..."

    # Define schema per table
    local create_table_sql
    case "$table_name" in
        accounts)
            create_table_sql="CREATE TABLE IF NOT EXISTS accounts (
                id INT PRIMARY KEY,
                name VARCHAR(100),
                website VARCHAR(255),
                lat FLOAT,
                long FLOAT,
                primary_poc VARCHAR(100),
                sales_rep_id INT
            );"
            ;;
        orders)
            create_table_sql="CREATE TABLE IF NOT EXISTS orders (
                id INT PRIMARY KEY,
                account_id INT,
                occurred_at TIMESTAMP,
                standard_qty INT,
                gloss_qty INT,
                poster_qty INT,
                total INT,
                standard_amt_usd DECIMAL,
                gloss_amt_usd DECIMAL,
                poster_amt_usd DECIMAL,
                total_amt_usd DECIMAL
            );"
            ;;
        region)
            create_table_sql="CREATE TABLE IF NOT EXISTS region (
                id INT PRIMARY KEY,
                name VARCHAR(100)
            );"
            ;;
        sales_reps)
            create_table_sql="CREATE TABLE IF NOT EXISTS sales_reps (
                id INT PRIMARY KEY,
                name VARCHAR(100),
                region_id INT
            );"
            ;;
        web_events)
            create_table_sql="CREATE TABLE IF NOT EXISTS web_events (
                id INT PRIMARY KEY,
                account_id INT,
                occurred_at TIMESTAMP,
                channel VARCHAR(50)
            );"
            ;;
        *)
            echo "No schema defined for $table_name. Skipping..."
            return 1
            ;;
    esac

    # Create table if not exists
    run_psql "$create_table_sql"

    # Truncate if reset mode enabled
    if [ "$RESET" = true ]; then
        echo "Resetting (truncating) $table_name..."
        run_psql "TRUNCATE TABLE $table_name;"
    fi

    # Copy CSV into the container
    docker cp "$file_path" "$POSTGRES_CONTAINER_NAME":/tmp/"$file_name"

    # Import CSV
    run_psql "\COPY $table_name FROM '/tmp/$file_name' CSV HEADER;"

    if [ $? -eq 0 ]; then
        echo "$table_name loaded successfully."
    else
        echo "Failed to load $table_name."
    fi
}

# Iterate over all CSV files
for csv_file in "$CSV_DIR"/*.csv; do
    if [ -f "$csv_file" ]; then
        load_csv "$csv_file"
    else
        echo "No CSV files found in $CSV_DIR"
        break
    fi
done

echo "All CSV files processed."
