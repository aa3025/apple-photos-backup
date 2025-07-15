#!/bin/bash
# you need to have exiftool installed on your system!

user=$USER

# copy from:
src_folder="/Volumes/$USER/Pictures/Photos Library/"
# copy to:
destination_folder=/Volumes/my_backup_drive/photos

find /Users/aa3025/Pictures/Photos\ Library.photoslibrary/originals -maxdepth 2 -mindepth 2 -type f -exec /Users/aa3025/Pictures/process_photos.sh {} "src_folder" "$destination_folder" \;

