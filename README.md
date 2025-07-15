# apple-photos-backup
bash scripts for copying all your photos from MacOS Photos Library

Pre-requisites: exiftool installed on your system https://exiftool.org/

The script assumes the standard location of your Photos Library on MacOS, though you can change it if necessary in backup_photos.sh script.

The backup is organised by year/month/camera model/shutter_count when photo was taken based on EXIF data (you can customise that if needed in the "process_photos.sh" script.

You need to specify the target directory for backup, see photos_backup.sh.
