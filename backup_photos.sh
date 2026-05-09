#!/bin/bash
# you need to have exiftool installed on your system!

user=$USER

# copy from:
#src_folder="/Volumes/aa3025_1TB/Pictures/Photos Library 2.photoslibrary/originals"
#src_folder="/Volumes/aa3025_1TB/Pictures/Photos Library.photoslibrary/originals"
#src_folder="/Volumes/Elements-aa3025/OLD_PHOTOS_BACKUP_1TB_HDD/Photos_Backup"
#src_folder="/Volumes/aa3025_1TB/TMP/5_May_2026"
#src_folder="/Volumes/Elements-aa3025/OLD_PHOTOS_BACKUP_1TB_HDD/iCloud_old"
src_folder="/Volumes/Elements-aa3025/Downloads/Takeout/"
src_folder="/Volumes/Elements-aa3025/Amazon_Photos/Amazon Photos Downloads/Pictures"
# copy to:
#destination_folder="/Volumes/Elements-aa3025/Gallery"
#destination_folder="/Volumes/Elements-aa3025/GOOGLE_PHOTOS"
destination_folder="/Volumes/Elements-aa3025/OLD_PHOTOS_BACKUP_1TB_HDD/PHOTOS"


find "$src_folder" -maxdepth 4 -mindepth 2 -type f ! \( -name "*.json" -o -name "*.JSON" \) -exec ./process_photos.sh {} "$destination_folder/" \;
