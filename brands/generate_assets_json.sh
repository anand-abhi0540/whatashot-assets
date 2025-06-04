#!/bin/bash

output_file="assets.json"
echo "[" > "$output_file"
first_entry=true

for brand_dir in */; do
  brand_folder=$(basename "$brand_dir")  # Keep as-is for constructing URL

  # Human-readable fields for JSON
  brand=$(echo "$brand_folder" | cut -d'-' -f1 | sed 's/_/ /g')
  sector=$(echo "$brand_folder" | cut -d'-' -f2 2>/dev/null | sed 's/_/ /g')
  theme=$(echo "$brand_folder" | cut -d'-' -f3- 2>/dev/null | sed 's/_/ /g')

  for service_dir in "$brand_dir"*/; do
    service_folder=$(basename "$service_dir")  # Keep as-is for URL
    service_type=$(echo "$service_folder" | sed 's/_/ /g')  # Human-readable

    for file_path in "$service_dir"*; do
      [ -f "$file_path" ] || continue

      # Rename file if it contains spaces
      original_filename=$(basename "$file_path")
      safe_filename=$(echo "$original_filename" | sed 's/ /_/g')
      safe_path="$(dirname "$file_path")/$safe_filename"

      if [ "$original_filename" != "$safe_filename" ]; then
        mv "$file_path" "$safe_path"
        file_path="$safe_path"
      fi

      extension="${safe_filename##*.}"
      lowercase_ext=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

      if [[ "$lowercase_ext" =~ ^(jpg|jpeg|png|gif|webp)$ ]]; then
        type="image"
      elif [[ "$lowercase_ext" =~ ^(mp4|mov|webm|mkv|m4v)$ ]]; then
        type="video"
      else
        continue
      fi

      # URL path: brands/<brand-folder>/<service-folder>/<file>
      relative_url="brands/${brand_folder}/${service_folder}/${safe_filename}"

      if [ "$first_entry" = true ]; then
        first_entry=false
      else
        echo "," >> "$output_file"
      fi

      echo "  {" >> "$output_file"
      echo "    \"brand\": \"$brand\"," >> "$output_file"
      echo "    \"sector\": \"${sector:-}\"," >> "$output_file"
      echo "    \"theme\": \"${theme:-}\"," >> "$output_file"
      echo "    \"service_type\": \"$service_type\"," >> "$output_file"
      echo "    \"filename\": \"$safe_filename\"," >> "$output_file"
      echo "    \"type\": \"$type\"," >> "$output_file"
      echo "    \"alt\": \"$service_type\"," >> "$output_file"
      echo "    \"url\": \"$relative_url\"" >> "$output_file"
      echo -n "  }" >> "$output_file"
    done
  done
done

echo "" >> "$output_file"
echo "]" >> "$output_file"

echo "✅ JSON with URLs generated in $output_file"
