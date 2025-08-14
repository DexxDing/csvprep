#!/bin/bash

# Usage: ./csv_to_txt.sh input.csv output.txt

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.csv output.txt"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file '$INPUT_FILE' does not exist."
    exit 1
fi

# Convert CSV to TXT (remove quotes and keep commas)
# You can modify this to use tab or space if you prefer
cat "$INPUT_FILE" | tr -d '"' > "$OUTPUT_FILE"

echo "Conversion complete. Output saved to: $OUTPUT_FILE"
