# apple-photos-backup
bash scripts for copying all your photos from MacOS Photos Library

Pre-requisites: exiftool installed on your system https://exiftool.org/

The script assumes the standard location of your Photos Library on MacOS, though you can change it if necessary in backup_photos.sh script.

The backup is organised by year/month/day when photo was taken based on EXIF dates (CreateDate, fallback DateTimeOriginal).

Output filename format for dated files:

- with shutter count: YYYY_MM_DD_HH_MM_SS_CAMERA-SLUG_SHUTTERCOUNT.ext
- without shutter count: YYYY_MM_DD_HH_MM_SS_CAMERA-SLUG_ORIGINALSTEM.ext

Examples:

- 2026_04_06_15_16_35_NIKON-D3300_12345.jpg
- 2026_04_06_15_16_35_NIKON-D3300_DSC_0255.jpg

Notes:

- Destination path slashes are normalized, so trailing slash in destination input does not create double slashes.
- JSON files are skipped by backup_photos.sh.
- For files without usable EXIF date, process_photos.sh places them in no-time-data/.

You need to specify the target directory for backup, see backup_photos.sh.

Edit (backup destination etc) and then run backup_photos.sh, the 2nd script process_photos.sh must be present in the same directory.

## Reorganize existing month folders into day folders

If you already have files directly inside year/month folders, use:

move_month_files_into_day_folders.sh

This script:

- scans only year/month folders (YYYY/MM)
- does not read EXIF (fast)
- uses filename prefix YYYY_MM_DD_...
- moves matching files into YYYY/MM/DD
- supports --dry-run

Usage:

./move_month_files_into_day_folders.sh /path/to/destination/root --dry-run
./move_month_files_into_day_folders.sh /path/to/destination/root
