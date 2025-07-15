#!/bin/bash

# Invocation
# find /path/to/your/main_directory -maxdepth 2 -mindepth 2 -type f -exec /path/to/your/process.sh {} "destination_dir" \;

filename=$1
dest=$2

# Extracting EXIF data
ext="${filename##*.}"

frame=$(exiftool -s3 -ShutterCount "$filename")
model=$(exiftool -s3 -Model "$filename")
camera="${model// /-}"

if [ "model"x != "x" ]; then
    name=${camera}_${frame}.${ext}
else
    name=$(basename "$filename")
fi

year=$(exiftool -s3 -CreateDate -d "%Y" "$filename")
month=$(exiftool -s3 -CreateDate -d "%m" "$filename")
day=$(exiftool -s3 -CreateDate -d "%d" "$filename")
time=$(exiftool -s3 -CreateDate -d "%H_%M_%S" "$filename")


if [ "$year"x = "x" ]; then
    year=$(exiftool -s3 -DateTimeOriginal -d "%Y" "$filename")
    month=$(exiftool -s3 -DateTimeOriginal -d "%m" "$filename")
    day=$(exiftool -s3 -DateTimeOriginal -d "%d" "$filename")
    time=$(exiftool -s3 -DateTimeOriginal -d "%H_%M_%S" "$filename")
fi




if [ "$year"x = "x" ]; then
      # No time data found in EXIF
    destination="$dest/no-time-data"
    mkdir -p ${destination}
    name=$(basename "$filename")
    cp "$filename" "${destination}/${name}"
    echo "$filename" " --> " "${destination}/${name}"
else
    destination="$dest/$year/$month"
    mkdir -p ${destination}
    cp "$filename" "${destination}/${year}_${month}_${day}_${time}_${name}"
    echo "$filename" " --> " "${destination}/${year}_${month}_${day}_${time}_${name}"
fi




