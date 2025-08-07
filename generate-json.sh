#!/bin/bash

BASE_DIR="brands"
TEMP_FILE="temp_unsorted.json"
OUTPUT_FILE="output.json"
IMG_THUMBNAIL_DIR="img-thumbnails"
VIDEO_THUMBNAIL_DIR="thumbnails"

# Ensure jq is available
if ! command -v jq &> /dev/null; then
  echo "❌ 'jq' is required but not installed. Install it with: brew install jq"
  exit 1
fi

echo "[" > "$TEMP_FILE"
first=1

find "$BASE_DIR" -mindepth 3 -type f | while read -r filepath; do
  filename=$(basename "$filepath")

  # Skip hidden/system files
  [[ "$filename" == .* ]] && continue

  service_type=$(basename "$(dirname "$filepath")")
  brand_folder=$(basename "$(dirname "$(dirname "$filepath")")")

  IFS='-' read -r brand_part sector_part theme <<< "$brand_folder"

  brand="${brand_part//_/ }"
  sector="${sector_part//_/ }"

  extension="${filename##*.}"
  lowercase_ext=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
  base_filename="${filename%.*}"

  # Determine type and thumbnail folder
  if [[ "$lowercase_ext" =~ ^(jpg|jpeg|png|gif|webp)$ ]]; then
    type="image"
    thumbnail_folder="$IMG_THUMBNAIL_DIR"
  elif [[ "$lowercase_ext" =~ ^(mp4|mov)$ ]]; then
    type="video"
    thumbnail_folder="$VIDEO_THUMBNAIL_DIR"
  else
    continue
  fi

  thumbnail="${thumbnail_folder}/${base_filename}.jpg"

  escape() {
    echo "$1" | sed 's/"/\\"/g'
  }

  if [ "$first" -eq 0 ]; then
    echo "," >> "$TEMP_FILE"
  fi
  first=0

  cat <<EOF >> "$TEMP_FILE"
  {
    "brand": "$(escape "$brand")",
    "sector": "$(escape "$sector")",
    "theme": "$(escape "$theme")",
    "service_type": "$(escape "$service_type")",
    "filename": "$(escape "$filename")",
    "type": "$type",
    "alt": "$(escape "$service_type")",
    "url": "$(escape "$filepath")",
    "thumbnail": "$thumbnail"
  }
EOF

done

echo "]" >> "$TEMP_FILE"

# Sort by brand
jq 'sort_by(.brand)' "$TEMP_FILE" > "$OUTPUT_FILE"
rm "$TEMP_FILE"

echo "✅ Sorted JSON saved to $OUTPUT_FILE"
