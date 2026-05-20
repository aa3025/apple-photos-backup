#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 <destination_root> [--dry-run]"
    echo "Example: $0 /Volumes/Elements-aa3025/OLD_PHOTOS_BACKUP_1TB_HDD/PHOTOS --dry-run"
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage
    exit 1
fi

dest_root="$1"
dry_run=0

if [ "${2:-}" = "--dry-run" ]; then
    dry_run=1
elif [ "${2:-}" != "" ]; then
    usage
    exit 1
fi

if [ ! -d "$dest_root" ]; then
    echo "ERROR: Destination root does not exist: $dest_root"
    exit 1
fi

moved=0
skipped=0
conflicts=0
scanned=0

for year_dir in "$dest_root"/*; do
    [ -d "$year_dir" ] || continue
    year="$(basename "$year_dir")"

    if ! [[ "$year" =~ ^[0-9]{4}$ ]]; then
        continue
    fi

    for month_dir in "$year_dir"/*; do
        [ -d "$month_dir" ] || continue
        month="$(basename "$month_dir")"

        if ! [[ "$month" =~ ^[0-9]{2}$ ]]; then
            continue
        fi

        while IFS= read -r -d '' file; do
            scanned=$((scanned + 1))
            base="$(basename "$file")"

            if [[ "$base" =~ ^([0-9]{4})_([0-9]{2})_([0-9]{2})_ ]]; then
                file_year="${BASH_REMATCH[1]}"
                file_month="${BASH_REMATCH[2]}"
                day="${BASH_REMATCH[3]}"

                if [ "$file_year" != "$year" ] || [ "$file_month" != "$month" ]; then
                    echo "SKIP (path/date mismatch): $file"
                    skipped=$((skipped + 1))
                    continue
                fi

                if ! [[ "$day" =~ ^(0[1-9]|[12][0-9]|3[01])$ ]]; then
                    echo "SKIP (invalid day): $file"
                    skipped=$((skipped + 1))
                    continue
                fi

                day_dir="$month_dir/$day"
                target="$day_dir/$base"

                if [ -e "$target" ]; then
                    echo "SKIP (target exists): $target"
                    conflicts=$((conflicts + 1))
                    continue
                fi

                if [ "$dry_run" -eq 1 ]; then
                    echo "MOVE: $file -> $target"
                else
                    mkdir -p "$day_dir"
                    mv "$file" "$target"
                    echo "MOVED: $file -> $target"
                fi

                moved=$((moved + 1))
            else
                echo "SKIP (no YYYY_MM_DD prefix): $file"
                skipped=$((skipped + 1))
            fi
        done < <(find "$month_dir" -mindepth 1 -maxdepth 1 -type f -print0)
    done
done

echo ""
echo "Summary:"
echo "  scanned   : $scanned"
echo "  moved     : $moved"
echo "  skipped   : $skipped"
echo "  conflicts : $conflicts"

if [ "$dry_run" -eq 1 ]; then
    echo ""
    echo "Dry run only. No files were changed."
fi
