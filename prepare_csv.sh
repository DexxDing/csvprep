#!/usr/bin/env bash
set -euo pipefail

DETAIL_CSV="ADNI100-detail.csv"
FILES_TXT="files.txt"
OUT_CSV="ADNI100-detail-enriched.csv"

# 1) Write a single header line with the new columns
#    We read the original header and append our new fields.
read -r header_line < "$DETAIL_CSV"
echo "${header_line},time,image_path,segm_path" > "$OUT_CSV"

# 2) Read the rest of the file, line by line
tail -n +2 "$DETAIL_CSV" | while IFS=',' read -r image_uid subject_id rest; do
  # 'rest' now contains everything after the first two commas (diagnosis…Downloaded)
  # so we can reassemble it unmodified.
  
  # 3) Find the matching path in files.txt
  #    We look for directories containing "/<subject_id>/" and ending in "<image_uid>.nii"
  match=$(grep "/${subject_id}/.*${image_uid}\.nii\$" "$FILES_TXT" || true)
  if [[ -z "$match" ]]; then
    echo "Warning: no match for ${subject_id} / ${image_uid}" >&2
    continue
  fi

  # 4) Extract the timestamp folder (YYYY-MM-DD_hh:mm:ss.d)
  time_stamp=$(echo "$match" \
    | sed -E 's|.*/([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}\.[0-9]+)/.*|\1|; s/_/:/g; s/_/:/3')

  # 5) Build image_path and segm_path
  image_path="$match"
  parent_dir=$(dirname "$match")
  segm_path="${parent_dir}/segm.nii.gz"

  # 6) Append a line to the output CSV:
  #    image_uid,subject_id,rest...,time,image_path,segm_path
  echo "${image_uid},${subject_id},${rest},${time_stamp},${image_path},${segm_path}" \
    >> "$OUT_CSV"
done

echo "Wrote enriched data to $OUT_CSV"

