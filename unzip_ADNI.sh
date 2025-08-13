#!/usr/bin/env bash
shopt -s nullglob

# Loop over all files matching GO-test(100))*.zip
for zip in GO-test\(100\)\)*.zip; do
  echo "Extracting $zip…"
  # Unzip into a folder named after the zip (without .zip)
  outdir="${zip%.zip}"
  mkdir -p "$outdir"
  unzip -o "$zip" -d "$outdir"
done



