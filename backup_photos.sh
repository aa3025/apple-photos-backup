#!/bin/bash

find /Users/aa3025/Pictures/Photos\ Library.photoslibrary/originals -maxdepth 2 -mindepth 2 -type f -exec /Users/aa3025/Pictures/process_photos.sh {} \;

