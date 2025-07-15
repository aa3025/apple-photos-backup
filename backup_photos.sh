#!/bin/bash
# you need to have exiftool installed on your system!

user=$USER

# copy from:
src_folder="/Users/$USER/Pictures/Photos Library.photoslibrary/originals"

# copy to:
destination_folder="/Volumes/photos/PHOTOS"

find "$src_folder" -maxdepth 2 -mindepth 2 -type f -exec ./process_photos.sh {} "$destination_folder/" \;


src_folder="/Volumes/photos/Pictures/Photos Library.photoslibrary/originals"

# copy to:
destination_folder="/Volumes/photos/PHOTOS"

find "$src_folder" -maxdepth 2 -mindepth 2 -type f -exec ./process_photos.sh {} "$destination_folder/" \;



