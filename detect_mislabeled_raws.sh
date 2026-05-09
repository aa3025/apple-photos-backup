#!/bin/bash
# Detect mislabeled RAW files in a photo gallery.
# Usage: ./detect_mislabeled_raws.sh /path/to/gallery [output_report.txt]

GALLERY_PATH="${1:-.}"
REPORT_FILE="${2:-mislabeled_raws_report.txt}"

if [ ! -d "$GALLERY_PATH" ]; then
    echo "Error: Gallery path '$GALLERY_PATH' is not a directory."
    exit 1
fi

# RAW extension list (lowercase for case-insensitive matching)
RAW_EXTENSIONS="nef|nrw|cr2|cr3|crw|arw|srf|sr2|orf|raf|rw2|raw|dng|kdc|dcr|erf|3fr|mef|pef|x3f"

# Initialize report
> "$REPORT_FILE"

echo "Scanning gallery: $GALLERY_PATH"
echo "Report will be written to: $REPORT_FILE"
echo ""

MISLABELED_COUNT=0
CORRECT_COUNT=0

# Find all files with RAW extensions
find "$GALLERY_PATH" -type f | while read -r file; do
    filename=$(basename "$file")
    extension="${filename##*.}"
    extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Check if file has RAW extension
    if echo "$extension_lower" | grep -qE "^(${RAW_EXTENSIONS})$"; then
        # Get actual file type using exiftool
        file_type=$(exiftool -s3 -FileType "$file" 2>/dev/null)
        
        if [ -z "$file_type" ]; then
            file_type="UNKNOWN"
        fi
        
        # Normalize file type to lowercase for comparison
        file_type_lower=$(echo "$file_type" | tr '[:upper:]' '[:lower:]')
        
        # Check if actual type matches expected RAW type (approximate check)
        case "$file_type_lower" in
            nef|nrw|cr2|cr3|crw|arw|srf|sr2|orf|raf|rw2|raw|dng|kdc|dcr|erf|3fr|mef|pef|x3f)
                # Correct RAW file
                echo "[OK] $file -> FileType: $file_type" >> "$REPORT_FILE"
                ((CORRECT_COUNT++))
                ;;
            *)
                # Mislabeled file
                echo "[MISMATCH] $file" >> "$REPORT_FILE"
                echo "           Extension: .$extension_lower" >> "$REPORT_FILE"
                echo "           Actual Type: $file_type" >> "$REPORT_FILE"
                
                # Check for companion RAW file
                dir=$(dirname "$file")
                base=$(basename "$file" ".$extension")
                
                # Look for numeric suffix companion (e.g., file_38165.NEF)
                companion=$(find "$dir" -maxdepth 1 -type f -name "${base}_[0-9]*.${extension}" 2>/dev/null | head -1)
                if [ -n "$companion" ]; then
                    companion_type=$(exiftool -s3 -FileType "$companion" 2>/dev/null)
                    echo "           Companion: $(basename "$companion")" >> "$REPORT_FILE"
                    echo "           Companion Type: $companion_type" >> "$REPORT_FILE"
                fi
                
                echo "" >> "$REPORT_FILE"
                ((MISLABELED_COUNT++))
                ;;
        esac
    fi
done

# Print summary
echo ""
echo "=== SUMMARY ===" | tee -a "$REPORT_FILE"
echo "Total mislabeled files: $MISLABELED_COUNT" | tee -a "$REPORT_FILE"
echo "Total correct RAW files: $CORRECT_COUNT" | tee -a "$REPORT_FILE"
echo ""
echo "Report saved to: $REPORT_FILE"
echo "View with: cat $REPORT_FILE"
