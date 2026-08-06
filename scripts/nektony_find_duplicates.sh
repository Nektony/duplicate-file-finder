#!/bin/bash
#
# Nektony Duplicate File Finder — Terminal (MD5) method
# https://nektony.com/blog/how-to-find-duplicate-files-on-mac
#
# What it does:
# - Recursively scans a folder you specify
# - Calculates an MD5 hash for every file (compares content, not names or dates)
# - Groups files with identical hashes — identical content, byte for byte
# - Saves grouped results to ~/Documents/DuplicatesIn_<FolderName>_Folder.txt
#
# This script only FINDS duplicates and writes a report — it does NOT delete
# anything. Review the report and remove unwanted copies manually.
#
# Requirements:
# - Terminal needs Full Disk Access to scan Desktop, Documents, and Downloads
#   (System Settings → Privacy & Security → Full Disk Access)
# - Hashing thousands of files takes time — for very large folders, expect to wait
#
# Tested on: macOS [версии — заменить на реальные, напр. "Sequoia 15.x, Sonoma 14.x"]
# License: MIT
# Copyright (c) 2026 Nektony
#

# Request path to folder
read -p "Enter the absolute path to the folder to scan: " TARGET_DIR

# Checking for folder existence
if [ ! -d "$TARGET_DIR" ]; then
  echo "Folder not found. Finishing."
  exit 1
fi

# Get folder name from path
FOLDER_NAME=$(basename "$TARGET_DIR")

# Path for the resulting file
OUTPUT_FILE="$HOME/Documents/DuplicatesIn_${FOLDER_NAME}_Folder.txt"

echo "Search for files begins. Wait a little bit..."
find "$TARGET_DIR" -type f -exec test -f {} \; -print \
| while IFS= read -r file; do
    md5 "$file"
done \
| sed -E 's/^MD5 \((.*)\) = (.*)$/\2\t\1/' \
| sort \
| awk -F '\t' '
{
    hash = $1
    file = $2
    files[hash] = files[hash] ? files[hash] ORS file : file
}
END {
    group = 1
    for (h in files)
        if (split(files[h], a, ORS) > 1) {
            print "DUPLICATE Files, group #" group ".  MD5 = " h ":\n" files[h] "\n"
            group++
        }

# Final saving of results
}' > "$OUTPUT_FILE"
echo "Thank you! You can find the result here: $OUTPUT_FILE"
