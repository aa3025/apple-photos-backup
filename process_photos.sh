#!/bin/bash

# Invocation
# find /path/to/your/main_directory -maxdepth 2 -mindepth 2 -type f -exec /path/to/your/process.sh {} "destination_dir"\;

filename=$1
dest=$2

# Extracting EXIF data
name=$(basename $filename)
year=$(exiftool "$filename" | grep Create | head -1 | cut -d':' -f2 | tr -d ' ')
month=$(exiftool "$filename" | grep Create | head -1 | cut -d':' -f3 | tr -d ' ')

echo $year "   "  $month "   "  $filename


if [ -n "$year" ]; then
    destination="$dest/year/$month"
else
  # No time data found in EXIF
  destination="$dest/no-time-data"
fi

if [ -n "$destination" ]; then
    mkdir -p "$destination"
    cp "$filename" "$destination/"
fi
