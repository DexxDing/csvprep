#!/usr/bin/env bash
shopt -s nullglob

# Loop over all entries in the current directory
for dir in *; do
  # Only process directories
  if [[ -d "$dir" ]]; then
    # Compute new name by deleting parentheses
    new="${dir//[\(\)]/}"
    # If the name actually changes, rename it
    if [[ "$new" != "$dir" ]]; then
      echo "Renaming '$dir' → '$new'"
      mv -- "$dir" "$new"
    fi
  fi
done

