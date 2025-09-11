#!/bin/bash

# The directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source and destination folders
SRC_DIR="$PROJECT_ROOT/Random_Files"
DEST_DIR="$PROJECT_ROOT/json_and_CSV"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Count files before move
before_count=$(find "$DEST_DIR" -type f \( -name "*.csv" -o -name "*.json" \) | wc -l)

# Move all CSV and JSON files
echo "----- Moving CSV and JSON files..... -----"
find "$SRC_DIR" -type f \( -name "*.csv" -o -name "*.json" \) -exec mv {} "$DEST_DIR" \;

# Count files after move
after_count=$(find "$DEST_DIR" -type f \( -name "*.csv" -o -name "*.json" \) | wc -l)

# Check the difference
moved_count=$((after_count - before_count))

if [ "$moved_count" -gt 0 ]; then
    echo "$moved_count file(s) successfully moved to json_and_CSV folder"
else
    echo "No new file(s) moved."
fi
