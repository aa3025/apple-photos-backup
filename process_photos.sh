#!/bin/bash

# Invocation
# find /path/to/your/main_directory -maxdepth 2 -mindepth 2 -type f -exec /path/to/your/process.sh {} \;

destination=/Volumes/photos/PHOTOS/

filename=$1
name=$(basename $filename)
year=$(exiftool "$filename" | grep Create | head -1 | cut -d':' -f2 | tr -d ' ')
month=$(exiftool "$filename" | grep Create | head -1 | cut -d':' -f3 | tr -d ' ')

echo $year "   "  $month "   "  $filename


if [ -n "$year$month" ]; then
 mkdir -p $destination/$year/$month
 echo "Creating $destination/$year/$month"
 cp "$filename" $destination/$year/$month/
else
  echo "No time data"
fi
