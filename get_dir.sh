#!/usr/bin/env bash
#
# get_dir.sh
# Usage: ./get_dir.sh [BASEDIR] [PATTERN]
#   BASEDIR:   root folder to search (default: current directory)
#   PATTERN:   glob pattern for top‐level dirs (default: "*")
#
# Outputs:
#   files.txt    – one file path per line
#   parents.txt  – corresponding parent directory per file

set -euo pipefail

# --- Configuration (can also be passed as $1, $2) ---
BASEDIR="${1:-$(pwd)}"
PATTERN="${2:-"*"}"

# Output files (will be overwritten)
FILES_OUT="files.txt"
PARENTS_OUT="parents.txt"
> "$FILES_OUT"
> "$PARENTS_OUT"

# Find matching top‐level directories
echo "Searching in '$BASEDIR' for folders matching '$PATTERN'..."
shopt -s nullglob
topdirs=("$BASEDIR"/$PATTERN)

if [ ${#topdirs[@]} -eq 0 ]; then
  echo "No directories found." >&2
  exit 1
fi

# Loop each folder
for dir in "${topdirs[@]}"; do
  [ -d "$dir" ] || continue
  echo "Processing: $dir"

  # Find all files under $dir
  while IFS= read -r -d '' file; do
    parent="$(dirname "$file")"
    echo "$file"   >> "$FILES_OUT"
    echo "$parent" >> "$PARENTS_OUT"
  done < <(find "$dir" -type f -print0)
done

echo "Done.  
- File paths → $FILES_OUT  
- Parent dirs → $PARENTS_OUT"

