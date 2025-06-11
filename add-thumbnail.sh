#!/bin/bash

INPUT_FILE="assets.json"
OUTPUT_FILE="assets-with-thumbnails.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "❌ 'jq' is required but not installed. Install it with 'sudo apt install jq' or 'brew install jq'."
  exit 1
fi

# Process the JSON
jq 'map(
  if .type == "video" and .filename then
    . + {thumbnail: ("thumbnails/" + (.filename | sub("\\.mp4$"; "") + ".jpg"))}
  else
    .
  end
)' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✅ Processed file saved to $OUTPUT_FILE"
