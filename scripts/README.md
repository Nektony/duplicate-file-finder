# nektony_find_duplicates.sh

Finds exact duplicate files on macOS by comparing file content (MD5 hash) — not filenames or dates — directly from Terminal, no app install required.

**Article:** [How to Find Duplicate Files on Mac](https://nektony.com/blog/how-to-find-duplicate-files-on-mac) — full walkthrough with screenshots, plus two other methods (Smart Folder search, or the Duplicate File Finder app) if you'd rather not use Terminal.

---

## What it does

- Recursively scans a folder you provide
- Calculates an MD5 hash for every file — catches duplicates regardless of filename or modification date
- Groups files that share an identical hash (exact, byte-for-byte duplicates)
- Writes a report to `~/Documents/DuplicatesIn_<FolderName>_Folder.txt`

## What it does NOT do

- **Does not delete anything.** It only writes a report — review it and remove files manually.
- **Does not detect similar (not-identical) files.** For near-duplicate photos or audio tracks, see the [Duplicate File Finder app](https://nektony.com/duplicate-finder-free/download) — it handles similarity matching and safe Trash-based removal with one-click restore.
- **No undo.** If you delete files directly from Terminal (`rm`), they bypass the Trash. Always review the report before deleting.

---

## Requirements

- **Full Disk Access for Terminal** — required to scan Desktop, Documents, and Downloads. Add it in System Settings → Privacy & Security → Full Disk Access.
- **Time.** Hashing thousands of files takes a while — for very large folders, expect to wait.
- Not beginner-friendly. If you're not comfortable in Terminal, the [Duplicate File Finder app](https://nektony.com/duplicate-finder-free/download) does the same job with a Removal History and one-click restore.


---

## Usage

```bash
# Download the script
curl -O https://raw.githubusercontent.com/Nektony/duplicate-file-finder/main/scripts/nektony_find_duplicates.sh

# Make it executable
chmod +x nektony_find_duplicates.sh

# Inspect before running
less nektony_find_duplicates.sh

# Run it — your own user permissions are enough for home-folder locations
./nektony_find_duplicates.sh

# For system folders or locations outside your home directory, use sudo instead
sudo ./nektony_find_duplicates.sh
```

When prompted, either type the full folder path or drag the folder from Finder into the Terminal window (dragging is safer — it handles spaces in paths automatically). Press Return to start the scan.

When it finishes, open the results file in Finder (`Cmd+Shift+G` → paste the path from the script's output) and review each group of duplicates before deleting anything.

---

## Issues / questions

[Open an issue](https://github.com/Nektony/duplicate-file-finder/issues) — we read them. Prefer a GUI with safer removal (Trash-based, undo history)? See the [Duplicate File Finder app](https://nektony.com/duplicate-finder-free/download).
