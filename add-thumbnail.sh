# #!/bin/bash

# INPUT_FILE="assets.json"
# OUTPUT_FILE="assets-with-thumbnails.json"

# # Check if jq is installed
# if ! command -v jq &> /dev/null; then
#   echo "❌ 'jq' is required but not installed. Install it with 'sudo apt install jq' or 'brew install jq'."
#   exit 1
# fi

# # Process the JSON
# jq 'map(
#   if .type == "video" and .filename then
#     . + {thumbnail: ("thumbnails/" + (.filename | sub("\\.mp4$"; "") + ".jpg"))}
#   else
#     .
#   end
# )' "$INPUT_FILE" > "$OUTPUT_FILE"

# echo "✅ Processed file saved to $OUTPUT_FILE"


#!/bin/bash

INPUT_FILE="assets.json"
OUTPUT_FILE="assets-with-thumbnails.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "❌ 'jq' is required but not installed. Install it with 'sudo apt install jq' or 'brew install jq'."
  exit 1
fi

# Process the JSON: add thumbnail for type=image
jq 'map(
  if .type == "image" and .filename then
    . + {thumbnail: ("img-thumbnails/" + (.filename | split(".") | .[0] + ".jpg"))}
  else
    .
  end
)' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✅ Image thumbnails added to $OUTPUT_FILE"
