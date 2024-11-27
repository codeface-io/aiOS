#!/bin/zsh

# Check if an argument is provided
if [[ $# -eq 0 ]] ; then
    echo 'Please provide an image filename.'
    exit 1
fi

# The first argument is the source image
SOURCE_IMAGE=$1

# Directory to save the resized images
OUTPUT_DIR="resized_icons"
mkdir -p $OUTPUT_DIR

# Array of icon sizes for macOS
sizes=(16 32 64 128 256 512 1024)

for size in $sizes; do 
  sips -z $size $size $SOURCE_IMAGE --out $OUTPUT_DIR/icon_${size}.png
done

echo "Icons resized and saved in $OUTPUT_DIR"