#!/bin/bash

# Invocation
# find /path/to/your/main_directory -maxdepth 2 -mindepth 2 -type f -exec /path/to/your/process.sh {} "destination_dir" \;

filename=$1
dest=$2
HASH_DEDUP=${HASH_DEDUP:-0}

sanitize_filename_component() {
    local input="$1"
    local sanitized

    # Keep only safe filename characters and collapse runs of separators.
    sanitized=$(printf '%s' "$input" | sed -E 's/[^A-Za-z0-9._-]+/_/g; s/_+/_/g; s/^[_.-]+//; s/[_.-]+$//')

    if [ -z "$sanitized" ]; then
        sanitized="unnamed"
    fi

    printf '%s' "$sanitized"
}

find_duplicate_by_hash() {
    local src_file="$1"
    local search_dir="$2"
    local src_hash
    local src_size

    if [ ! -d "$search_dir" ]; then
        return 1
    fi

    src_size=$(stat -f "%z" "$src_file" 2>/dev/null) || return 1

    src_hash=$(shasum -a 256 "$src_file" | awk '{print $1}')

    while IFS= read -r -d '' existing_file; do
        local existing_hash
        existing_hash=$(shasum -a 256 "$existing_file" | awk '{print $1}')
        if [ "$src_hash" = "$existing_hash" ]; then
            echo "$existing_file"
            return 0
        fi
    done < <(find "$search_dir" -maxdepth 1 -type f -size "${src_size}c" -print0)

    return 1
}

# Extracting EXIF data
original_basename="$(basename "$filename")"
original_stem="${original_basename%.*}"
source_ext="${original_basename##*.}"
ext="$(printf '%s' "$source_ext" | tr '[:upper:]' '[:lower:]')"

# Prefer real content type extension over source filename extension.
detected_ext="$(exiftool -s3 -FileTypeExtension "$filename" | tr '[:upper:]' '[:lower:]')"
if [ -n "$detected_ext" ]; then
    ext="$detected_ext"
fi

frame=$(exiftool -s3 -ShutterCount "$filename")
model=$(exiftool -s3 -Model "$filename")
camera="${model// /-}"

if [ -z "$frame" ]; then
    # Avoid empty suffixes (e.g. ..._NIKON-D700_.ext) when shutter count is missing.
    frame=$(shasum -a 1 "$filename" | awk '{print substr($1,1,10)}')
fi

if [ "$model"x != "x" ]; then
    name=${camera}_${frame}.${ext}
else
    name=${original_stem}.${ext}
fi

name=$(sanitize_filename_component "$name")

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
    mkdir -p "$destination"
    name=$(sanitize_filename_component "${original_stem}.${ext}")
    target_path="${destination}/${name}"
    duplicate_path=""
    if [ "$HASH_DEDUP" = "1" ]; then
        duplicate_path=$(find_duplicate_by_hash "$filename" "$destination")
    fi
    if [ -n "$duplicate_path" ]; then
        echo "SKIP (duplicate content): $filename == $duplicate_path"
    elif [ ! -e "$target_path" ]; then
        cp "$filename" "$target_path"
        echo "$filename" " --> " "$target_path"
    else
        echo "SKIP (exists): $target_path"
    fi
else
    destination="$dest/$year/$month"
    mkdir -p "$destination"
    target_name=$(sanitize_filename_component "${year}_${month}_${day}_${time}_${name}")
    target_path="${destination}/${target_name}"
    duplicate_path=""
    if [ "$HASH_DEDUP" = "1" ]; then
        duplicate_path=$(find_duplicate_by_hash "$filename" "$destination")
    fi
    if [ -n "$duplicate_path" ]; then
        echo "SKIP (duplicate content): $filename == $duplicate_path"
    elif [ ! -e "$target_path" ]; then
        cp "$filename" "$target_path"
        echo "$filename" " --> " "$target_path"
    else
        echo "SKIP (exists): $target_path"
    fi
fi




