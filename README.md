# apple-photos-backup

Bash scripts for copying and organizing photos from Apple Photos exports (or any source folder) using EXIF metadata.

## Requirements

- macOS or Linux shell environment
- `exiftool` installed: https://exiftool.org/

## What this repo does

- Reads files from a source folder configured in `backup_photos.sh`
- Extracts date/time and camera info in `process_photos.sh`
- Copies images into destination folders organized as `YYYY/MM/DD`
- Skips JSON sidecar files during backup scan

## Folder and filename layout

Destination layout:

- `DESTINATION/YYYY/MM/DD/`

Filename format for dated files:

- With shutter count: `YYYY_MM_DD_HH_MM_SS_CAMERA-SLUG_SHUTTERCOUNT.ext`
- Without shutter count: `YYYY_MM_DD_HH_MM_SS_CAMERA-SLUG_ORIGINALSTEM.ext`

If date metadata is not available, files are copied to:

- `DESTINATION/no-time-data/`

## Main scripts

- `backup_photos.sh`: set source and destination, then batch-process all files
- `process_photos.sh`: process one file and copy it to the normalized destination path

## Usage

1. Edit source and destination paths in `backup_photos.sh`.
2. Run:

```bash
./backup_photos.sh
```

## Notes

- Destination path input is normalized, so trailing slash differences do not change output structure.
- Existing files are not overwritten (`SKIP (exists)`).
- Optional hash-based duplicate check is available via `HASH_DEDUP=1`.
