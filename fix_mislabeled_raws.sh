#!/bin/bash
# Rename mislabeled pseudo-NEF files (JPEG with .NEF extension) to .JPG
# Usage: ./fix_mislabeled_raws.sh /path/to/gallery [--dry-run]

GALLERY_PATH="${1:-.}"
DRY_RUN="${2}"

if [ ! -d "$GALLERY_PATH" ]; then
    echo "Error: Gallery path '$GALLERY_PATH' is not a directory."
    exit 1
fi

echo "Scanning for pseudo-NEF files (*_.NEF, *_.nef) in: $GALLERY_PATH"
if [ "$DRY_RUN" = "--dry-run" ]; then
    echo "MODE: DRY RUN (no files will be renamed)"
fi
echo ""

RENAME_COUNT=0
SKIPPED_COUNT=0

# Find all files matching *_.NEF or *_.nef pattern
while read -r file; do
    dir=$(dirname "$file")
    filename=$(basename "$file")
    
    # Replace .NEF or .nef with .JPG (case-insensitive)
    new_filename=$(echo "$filename" | sed 's/\.[Nn][Ee][Ff]$/.JPG/')
    
    new_file="$dir/$new_filename"
    
    if [ -f "$new_file" ]; then
        echo "[SKIP] $filename (target already exists: $new_filename)"
        ((SKIPPED_COUNT++))
    else
        if [ "$DRY_RUN" = "--dry-run" ]; then
            echo "[RENAME] $filename -> $new_filename"
        else
            mv "$file" "$new_file"
            echo "[OK] $filename -> $new_filename"
        fi
        ((RENAME_COUNT++))
    fi
done < <(find "$GALLERY_PATH" -type f \( -name "*_.NEF" -o -name "*_.nef" \))

# Print summary
echo ""
echo "=== SUMMARY ===" 
echo "Files to rename: $RENAME_COUNT"
echo "Files skipped (conflict): $SKIPPED_COUNT"
echo ""

if [ "$DRY_RUN" = "--dry-run" ]; then
    echo "Dry run complete. Run without --dry-run to apply changes."
else
    echo "Rename complete!"
fi
