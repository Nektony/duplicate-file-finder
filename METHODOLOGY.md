# Evaluation Methodology for macOS Duplicate Finder Apps

*53 criteria. Weighted scoring. Reproducible testing protocol.*

**Version:** 3.6.2 (March 2026)
**License:** [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
**Interactive calculator:** [nektony.com/resources/duplicate-finder-calculator](https://nektony.com/resources/duplicate-finder-calculator)

---

## Table of contents

- [Overview](#overview)
- [Scope](#scope)
- [Terms and definitions](#terms-and-definitions)
- [Metrics](#metrics)
- [Scoring system](#scoring-system)
- [Level 1 — Must Have (safety)](#level-1--must-have-safety)
- [Level 2 — Should Have (functionality)](#level-2--should-have-functionality)
- [Level 3 — Nice to Have (extras)](#level-3--nice-to-have-extras)
- [Test datasets](#test-datasets)
- [Performance baseline](#performance-baseline)
- [Risks and common pitfalls](#risks-and-common-pitfalls)
- [Testing protocol](#testing-protocol)
- [Score calculation](#score-calculation)
- [Report template](#report-template)
- [FAQ](#faq)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Overview

This document defines a reproducible methodology for evaluating duplicate finder applications on macOS. It includes 53 criteria across 3 priority levels, a weighted scoring system, 7 standardized test datasets, and a step-by-step testing protocol.

The methodology is designed for QA engineers, technical reviewers, security researchers, and developers of system utilities. It prioritizes risk in the following order:

**Safety > Accuracy > Usability > Speed**

Safety criteria (Level 1) carry the highest weight because a single failure can result in irreversible data loss. A Level 1 failure disqualifies an application regardless of its total score.

---

## Scope

**What this methodology evaluates:**
- Detection accuracy (recall, precision)
- Data safety (confirmation, recoverability, system file protection)
- Functionality (search types, special sources, result handling)
- Stability and performance
- Accessibility and extra features

**What this methodology does not evaluate:**
- User interface design or visual aesthetics
- Pricing or business model
- Marketing claims
- Customer support quality
- Platform availability beyond macOS

---

## Terms and definitions

| Term | Definition |
|------|------------|
| **Exact duplicate** | Files with identical content (bit-for-bit match) |
| **Similar file** | Files with visual or audio similarity (not byte-for-byte identical) |
| **Duplicate group** | A set of 2+ files considered to be copies of each other |
| **Original** | The file that remains after duplicates are removed |
| **False positive (FP)** | A unique file incorrectly marked as a duplicate |
| **False negative (FN)** | A real duplicate that was not detected |

---

## Metrics

### Core metrics

| Metric | Abbreviation | Description |
|--------|-------------|-------------|
| True Positive | TP | Duplicate groups identified correctly |
| False Positive | FP | Unique files incorrectly marked as duplicates |
| False Negative | FN | Real duplicates that were not found |

### How we count TP/FP/FN (unit of measurement)

The unit of measurement is a **Duplicate Group** (a set of 2+ files).

- **TP:** An expected group is counted as found if the app found **all files in the group** and combined them into one group.
- **FP:** The number of groups that contain at least one unique file presented by the app as a duplicate (not an exact duplicate matched by content).
- **FN:** The number of Duplicate Groups the app **failed to find**, or found **incompletely** (at least one file missing).

### If the app otherwise groups files (merging/splitting)

- **Splitting** one expected group into several counts as **FN** (group found incompletely).
- **Merging** two expected groups into one counts as **FN** for both groups (incorrect grouping).
- Passing L1 requires **full and correct grouping** of Exact Duplicates.

### Calculated metrics

| Metric | Formula | What it measures | Target |
|--------|---------|-----------------|--------|
| Recall | `TP / (TP + FN)` | What portion of real duplicates were found? | ≥ 99% |
| Precision | `TP / (TP + FP)` | What portion of found items are truly duplicates? | 100% |

### Measurement scope

- **Recall** is measured on datasets DS1–DS4 (known number of duplicate groups).
- **Precision** (FP = 0) is checked on datasets DS1–DS6, where DS6 contains edge cases and traps.
- Results are averaged over 2–3 runs to eliminate random deviations.

### Example calculation

```
Dataset 3 (10,000 photos):
- Expected duplicate groups: 5,000
- Groups found: 4,980
- False positives: 0

Recall = 4980 / 5000 = 99.6%
Precision = 4980 / (4980 + 0) = 100%
```

---

## Scoring system

### Three levels of criteria

| Level | Name | Criteria | Weight | Max points |
|-------|------|----------|--------|------------|
| L1 | Must Have (safety) | 8 | ×3 | 24 |
| L2 | Should Have (functionality) | 23 | ×2 | 46 |
| L3 | Nice to Have (extras) | 22 | ×1 | 22 |
| | **Total** | **53** | | **92** |

### Weight rationale

- **L1 (×3):** A single safety failure can cause irreversible data loss. These criteria are non-negotiable.
- **L2 (×2):** Functional gaps limit real-world usability and can lead to incomplete results.
- **L3 (×1):** Extra features improve experience but their absence does not compromise safety or core functionality.

### Score interpretation

| Score | Recommendation |
|-------|----------------|
| 71–92 | Recommended |
| 46–70 | Recommended with caveats |
| < 46 | Not recommended |

These thresholds are based on the following reasoning:
- **71 (≈77% of max):** An app must pass all L1 criteria and most L2 criteria to be recommended without reservations.
- **46 (≈50% of max):** Below this threshold, significant functional gaps make the app unsuitable for most users.

**Disqualification rule:** Failing any Level 1 criterion results in "Not recommended," regardless of the total score.

---

## Level 1 — Must Have (safety)

Data safety criteria. Failing any of them means a real risk of file loss.

**If at least one L1 criterion is not met → Not recommended, regardless of the total score.**

| # | Criterion | Description |
|---|-----------|-------------|
| 1.1 | **Recall ≥ 99%** | The app must find almost all real duplicates |
| 1.2 | **False positives = 0%** | Unique files must never be marked as duplicates |
| 1.3 | **Removal confirmation** | Deletion only after explicit user confirmation |
| 1.4 | **Last file protection** | The app must prevent deleting ALL files in a group without special confirmation — at least one must remain |
| 1.5 | **File integrity** | Remaining originals must not be damaged |
| 1.6 | **System file protection** | Must not search for or show duplicates in ~/Library/ |
| 1.7 | **Stability** | No crashes on test sets (up to 200,000 files) |
| 1.8 | **Running without Full Disk Access** | Must run in Documents, Desktop, Downloads, etc. without Full Disk Access |

### L1 criteria — detailed descriptions

<details>
<summary><strong>1.1 Recall ≥ 99%</strong></summary>

**Why it matters:** The app must find all real duplicates. Missing duplicates means the user won't free the expected disk space.

**How to check:**

1. Scan the folder `~/DuplicateTest/` entirely.
2. Make a note of the number of groups and duplicates found.
3. Compare it with the expected numbers.
4. Calculate: Recall = Found / Expected × 100%

| Dataset | Expected groups | Found | Recall |
|---------|----------------|-------|--------|
| 1 | 230 | | |
| 2 | 50 | | |
| 3 | 5,000 | | |
| 4 | 1,000 | | |
| 5 | 100 | | |

**Result:**
- Pass: Recall ≥ 99% on all datasets
- Fail: Recall < 99%

</details>

<details>
<summary><strong>1.2 False positives = 0%</strong></summary>

**Why it matters:** Unique files must never be marked as duplicates. A mistake here can lead to loss of important data.

**How to check:**

1. Open 10 random groups in the scan results.
2. For each group, make sure that the files are truly identical:
   - Same size
   - Same content (open and compare)
3. Pay special attention to Dataset 1 (traps) and Dataset 6 (edge cases).
4. Make a note of the number of false positives found: ______

**Result:**
- Pass: False Positives = 0
- Fail: Unique files found in duplicate groups

</details>

<details>
<summary><strong>1.3 Removal confirmation</strong></summary>

**Why it matters:** An accidental click must not cause data loss. There must be a confirmation step.

**How to check:**

1. Select 3–5 files to be deleted.
2. Click Delete/Remove.
3. Is there a confirmation dialog?
4. Does it show:
   - Number of files
   - Space size to be freed
   - Where files will be deleted (Trash / permanently)

**Result:**
- Pass: The app shows confirmation with details
- Fail: The app deletes files immediately without confirmation

</details>

<details>
<summary><strong>1.4 Last file protection</strong></summary>

**Why it matters:** You must not be able to delete all files in a group — at least one must remain. Otherwise, all of the data will be lost.

**How to check:**

1. Find a group of 2 duplicates.
2. Try selecting BOTH files for removal.
3. Click Delete/Remove.
4. What happens?

**Result:**
- Pass: The app does not allow you to select both files
- Pass: The app allows you to select, but shows a warning before removal
- Fail: The app allows you to remove both files without warning

</details>

<details>
<summary><strong>1.5 File integrity</strong></summary>

**Why it matters:** After deleting a duplicate, the remaining original must not be damaged.

**How to check:**

1. After deleting a duplicate, locate the remaining original.
2. Open it with the appropriate app:
   - Photo → Preview or Photos
   - Video → QuickTime
   - Document → relevant app
3. Does it open fully and correctly?
4. Repeat for 3–5 various file types.

**Result:**
- Pass: All files open correctly
- Fail: At least one file is damaged or won't open

</details>

<details>
<summary><strong>1.6 System file protection</strong></summary>

**Why it matters:** The app must not suggest deleting system files from ~/Library/.

**How to check:**

1. Scan the `~/Library/` folder.
2. Check whether the app shows files from there in results.
3. If so, try selecting a file from `~/Library/Preferences/` for removal.

**Result:**
- Pass: The app does not scan ~/Library/ or does not show files from there in results
- Pass: The app shows them but blocks removal and explains the reason
- Warning: The app shows and warns, but allows removal
- Fail: The app allows you to delete system files without warning

</details>

<details>
<summary><strong>1.7 Stability</strong></summary>

**Why it matters:** The app must not crash, even on large datasets.

**How to check:**

1. Scan Dataset 4 (200,000 files).
2. During the scan, check:
   - If there are any crashes?
   - If there are any freezes (beachballs)?
3. In Activity Monitor, check:
   - RAM usage: _______ MB
   - If memory grows uncontrollably?

**Result:**
- Pass: The app is stable and completes the scan, RAM < 4 GB
- Fail: Crash, freeze or RAM > 4 GB

</details>

<details>
<summary><strong>1.8 Running without Full Disk Access</strong></summary>

**Why it matters:** The app must run for users who don't grant Full Disk Access.

**How to check:**

1. Disable Full Disk Access for the app: System Settings → Privacy & Security → Full Disk Access → toggle off
2. Restart the app.
3. Try scanning `~/Documents/`, `~/Desktop/`, `~/Downloads/`
4. See how the app behaves.

**Result:**
- Pass: The app allows you to select a folder and scan. Standard user folders can be scanned.
- Pass: There is a clear message if FDA is required for protected folders.
- Fail: Crash, unclear error, or the app does not run at all.

</details>

### Safety red flags

The following behaviors indicate a high risk of data loss:

- Allows deleting all files in a group without warning
- Deletes files immediately without confirmation
- Does not indicate where files are sent (Trash or permanently deleted)
- Crashes when scanning large file sets

---

## Level 2 — Should Have (functionality)

Functionality and usability criteria.

They cover search settings, performance, working with special sources (Photo Library, iCloud, external drives), and the quality of the results interface. Without these features, an app can still be used, but with limitations in certain scenarios.

Partial compliance = 0.5 points (before weight multiplier).

| # | Criterion | Description |
|---|-----------|-------------|
| 2.1 | **Minimum file size** | Option to skip small files |
| 2.2 | **Search types** | Files, folders, similar photos, similar audio |
| 2.3 | **Folder duplicates** | Option to find duplicate folders |
| 2.4 | **Skip list** | Option to toggle off folders, files, and extensions |
| 2.5 | **Baseline time** | Scanning speed is reasonable |
| 2.6 | **Pause/cancel** | Option to stop the scan |
| 2.7 | **Progress indicator** | Shows remaining scan progress |
| 2.8 | **External/network drives** | USB, NAS, SMB |
| 2.9 | **Photo Library** | Works with Photos.app |
| 2.10 | **Hidden files** | Finds dotfiles and files flagged as hidden |
| 2.11 | **Quick Look** | File preview before removal |
| 2.12 | **Path/size/date** | Full information for each file |
| 2.13 | **Why duplicate** | Shows hash or confirms "bit-for-bit" match |
| 2.14 | **Space to be freed** | Shows how much disk space will be freed |
| 2.15 | **Autoselect** | Automatic file selection |
| 2.16 | **Autoselect rules** | Configurable rules for automatic selection |
| 2.17 | **Open in Finder** | Option to open a file/folder in Finder |
| 2.18 | **Removal preview** | List of files before removal |
| 2.19 | **Trash vs Permanent** | Choice between moving to Trash or deleting permanently |
| 2.20 | **Restore deleted files** | Deleted files must go to Trash and be recoverable |
| 2.21 | **Error handling** | Clear error messages and option to keep going |
| 2.22 | **Help on error** | Suggestions on how to fix issues when errors occur |
| 2.23 | **Partial results** | Shows what succeeded and what failed if an error occurs |

### L2 criteria — detailed descriptions

#### Search settings

<details>
<summary><strong>2.1 Minimum file size</strong></summary>

**Why it matters:** The app lets you skip tiny files and focus on large duplicates that actually take up space.

**How to check:** Is there an option in settings to set a minimum file size?

- Pass: Yes, a specific value can be set
- Fail: No such setting

</details>

<details>
<summary><strong>2.2 Search type selection</strong></summary>

**Why it matters:** A user may only need one type of search — for example, file duplicates only, without similar photos. Choice saves time.

**How to check:** Can you choose what to search for?
- File duplicates
- Similar photos
- Similar audio

- Pass: Yes, multiple types to choose from
- Fail: Only one search type

</details>

<details>
<summary><strong>2.3 Folder duplicates</strong></summary>

**Why it matters:** Sometimes entire folders get duplicated (for example, project backups). Removing a whole folder is more efficient than file by file.

**How to check:** Is there a mode to find duplicate folders (not just files)?

- Pass: Yes, there is such mode
- Fail: No, files only

</details>

<details>
<summary><strong>2.4 Skip List</strong></summary>

**Why it matters:** It lets you skip folders you don't want scanned (node_modules, .git, caches) and speeds the search.

**How to check:** Can you skip folders, files, or extensions from the search?

- Pass: Yes (folders + files + extensions)
- Partial: In part (only one of these)
- Fail: No

</details>

#### Performance

<details>
<summary><strong>2.5 Baseline time</strong></summary>

**Why it matters:** If scanning is too slow, the app isn't practical for regular use.

**How to check:** Measure scan time and compare with the baseline:

| Dataset | Your result | Excellent | Acceptable | Unacceptable |
|---------|-------------|-----------|------------|--------------|
| 2 (large files) | ___ sec | < 30 sec | < 90 sec | > 180 sec |
| 3 (10K photos) | ___ sec | < 60 sec | < 180 sec | > 300 sec |
| 4 (200K files) | ___ min | < 5 min | < 15 min | > 30 min |

- Pass: Time is within "Excellent" or "Acceptable"
- Fail: Time falls under "Unacceptable"

</details>

<details>
<summary><strong>2.6 Cancel/pause</strong></summary>

**Why it matters:** Users need to control the process. If a scan runs too long, there must be a way to stop it.

**How to check:**

1. Start scanning a large folder (Dataset 4)
2. Are there Pause and Cancel buttons?
3. Do they work?

- Pass: Pause + cancel, both work
- Partial: Cancel only
- Fail: No way to stop

</details>

<details>
<summary><strong>2.7 Progress indicator</strong></summary>

**Why it matters:** Without a progress indicator, it's impossible to tell if the app is working or frozen. It's crucial for scanning large drives and folders.

**How to check:** Do you see progress during the scan?
- Progress bar
- Percentage complete
- Number of processed files
- Number of duplicates found

- Pass: Informative progress (2+ elements)
- Fail: No indicator or useless one (stuck at 99%)

</details>

#### Special sources

<details>
<summary><strong>2.8 External/network drives</strong></summary>

**Why it matters:** Duplicates often pile up on external drives and NAS. The app should handle different storage locations.

**How to check:**

1. Connect a USB drive and create a small test folder with duplicates
2. Does the app show it as a source?
3. Does scanning work?
4. (If so) Check NAS/SMB.

- Pass: USB + NAS work
- Partial: USB only
- Fail: Not supported

</details>

<details>
<summary><strong>2.9 Photo Library</strong></summary>

**Why it matters:** The Photos.app library is one of the largest duplicate sources for regular users. The app is supposed to handle this library.

**How to check:**

1. Select `~/Pictures/Photos Library.photoslibrary` as a source.
2. Run the scan.
3. Does it find duplicates inside the library?

- Pass: It scans and shows duplicates from Photo Library
- Partial: It shows the library as a file but does not show its photos as duplicates
- Fail: Not supported

</details>

<details>
<summary><strong>2.10 Hidden files</strong></summary>

**Why it matters:** Hidden files (dotfiles or flagged as hidden) can also be duplicates. Skipping them means an incomplete scan.

**How to check:**

1. Use Dataset 6 (Edge Cases) — hidden files are in there.
2. Or create `.hidden_test.txt` and a copy elsewhere.
3. Scan — are hidden duplicates found by the app?

- Pass: The app finds hidden files
- Fail: The app does not find them

</details>

#### Results interface

<details>
<summary><strong>2.11 Quick Look</strong></summary>

**Why it matters:** Quick Look is the standard macOS preview. Its availability lets you quickly review files before removal.

**How to check:** Select a file in results, press Space — does Quick Look work?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>2.12 Path/size/date</strong></summary>

**Why it matters:** This info helps you decide which file to keep based on directory, size, or modification date.

**How to check:** For each file in results, is the following shown:
- Full path
- File size
- Date modified (or date created)

- Pass: All info available (3/3)
- Partial: In part (1–2 out of 3)
- Fail: No info

</details>

<details>
<summary><strong>2.13 Why duplicate</strong></summary>

**Why it matters:** Algorithm transparency builds trust. Users should understand why files are considered duplicates.

**How to check:** Do results show why files are duplicates?
- Hash is shown (MD5, SHA)
- The "Bit-for-bit identical" message is shown
- Match by size + content is shown

- Pass: Reason shown
- Fail: Not shown

</details>

<details>
<summary><strong>2.14 Space to be freed</strong></summary>

**Why it matters:** The whole point of searching duplicates is to free up space. Users should see how much space they'll actually free up.

**How to check:** Can you see how much space will be freed after deleting selected files?

- Pass: Yes, I can see (for group or selected files)
- Fail: No, I can't see

</details>

<details>
<summary><strong>2.15 Autoselect</strong></summary>

**Why it matters:** With thousands of duplicates, manual selection isn't realistic. Autoselect saves time and reduces mistakes.

**How to check:** Is there an automatic selection feature?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>2.16 Autoselect rules</strong></summary>

**Why it matters:** Different users have different priorities: keep the newest file, keep files in a specific folder, etc.

**How to check:** Can you configure autoselect rules?
- Keep newest
- Keep oldest
- Keep by path (e.g., ~/Documents)
- Keep least nested

- Pass: There are configurable rules (2+)
- Partial: There is only one option
- Fail: No configuration (or no autoselect)

</details>

<details>
<summary><strong>2.17 Open in Finder</strong></summary>

**Why it matters:** Sometimes you need to see the file in its folder context — what files are next to it and what the folder's name is.

**How to check:** Can you open the file or folder in Finder directly from the results?

- Pass: Yes (right click or button)
- Fail: No

</details>

<details>
<summary><strong>2.18 Removal review</strong></summary>

**Why it matters:** It's the last chance to review what will be deleted. It is especially important to review selected files after using autoselect.

**How to check:** Can you review the full list of selected files before removal?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>2.19 Trash vs Permanent</strong></summary>

**Why it matters:** Trash is a safety net against accidental deletions. But sometimes you really do need to delete files permanently (for example, sensitive data). It's best when you have a choice.

**How to check:** Is there an option to either move files to Trash or delete them permanently?

- Pass: Both options are available
- Fail: Only one option is available

</details>

<details>
<summary><strong>2.20 Restore works</strong></summary>

**Why it matters:** If a file is deleted by mistake, there must be a way to recover it. The Trash provides the standard macOS recovery mechanism for that.

**How to check:**

1. Delete 2–3 files through the app.
2. Open Trash — are the files there?
3. Restore the file (right click → Put Back)
4. Does the file return to its original folder and open correctly?
5. Or, is there a restore command inside the app? (even better, you can immediately see "your" deleted files)

- Pass: Files are in Trash, restore works
- Fail: Files are permanently deleted or cannot be restored

</details>

<details>
<summary><strong>2.21 Error handling</strong></summary>

**Why it matters:** Errors are inevitable (locked files, no access permissions). The app should handle them gracefully without interrupting the entire process.

**How to check:**

1. Lock one duplicate file: Get Info → Locked ✓
2. Try deleting this file through the app.
3. What happens?

- Pass: Clear error message, removal of other files continues
- Fail: Crash, unclear error, or the entire process stops

</details>

<details>
<summary><strong>2.22 Help on error</strong></summary>

**Why it matters:** A good app not only reports an error but also suggests how to fix it.

**How to check:** When an error occurs, does the app suggest how to fix it?

- Pass: Yes, there is a suggestion (for example, "unlock the file")
- Fail: No, only an error message

</details>

<details>
<summary><strong>2.23 Partial results</strong></summary>

**Why it matters:** After an operation, the user should clearly understand what actually happened — how many files were removed, how many were not, and why.

**How to check:** If removal is partial (some files removed successfully, some failed) — does the app show what was removed and what wasn't?

- Pass: Yes, a detailed report
- Fail: No information

</details>

---

## Level 3 — Nice to Have (extras)

Extra features for advanced users. Accessibility (VoiceOver, localization), advanced result handling (sorting, search, export), and alternative actions (moving files to a chosen folder instead of deleting them, replacing duplicates with symlinks). Missing them is not critical, but availability makes the app more usable.

| # | Criterion | Description |
|---|-----------|-------------|
| 3.1 | Dark mode | Supports macOS system dark mode |
| 3.2 | VoiceOver | Accessible for visually impaired users |
| 3.3 | Localization | 5+ interface languages |
| 3.4 | Onboarding | First-launch tutorial |
| 3.5 | Help / support | Built-in help, FAQ, or support contact |
| 3.6 | Clear warnings | Warnings explain risk and recommended action |
| 3.7 | Side-by-side comparison | Compare two files next to each other |
| 3.8 | Sorting / grouping | Sort results by size, date, or path |
| 3.9 | Search in results | Filter or search within scan results |
| 3.10 | Metadata (EXIF) | Shows EXIF data for photos |
| 3.11 | Deselect All | Clear all selections with one click |
| 3.12 | Move instead of Delete | Move files to a chosen folder instead of deleting |
| 3.13 | Replace with symlink | Replace a duplicate with a symbolic link |
| 3.14 | Folder merge | Merge contents of duplicate folders |
| 3.15 | Export report | Export results to CSV, PDF, or txt |
| 3.16 | Session saving | Scan results preserved after quitting the app |
| 3.17 | Operation log | History of removed files |
| 3.18 | Add to Skip List | Add exclusions directly from results |
| 3.19 | Processing 200K+ files | Stable and responsive UI on large datasets |
| 3.20 | Interim results | Shows found duplicates before scan finishes |
| 3.21 | APFS clones | Detects clones and warns that removal won't free space |
| 3.22 | iCloud | Works correctly with evicted (cloud-only) files |

### L3 criteria — detailed descriptions

<details>
<summary><strong>3.1 Dark Mode</strong></summary>

**Why it matters:** Many macOS users prefer Dark Mode. A native app should automatically adapt to system appearance settings.

**How to check:** System Settings → Appearance → Dark. Does the app switch to Dark Mode?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.2 VoiceOver</strong></summary>

**Why it matters:** Visually impaired users should also be able to use the app. VoiceOver support is a sign of a well-built native app.

**How to check:** Enable VoiceOver (Cmd+F5) and try navigating. Are key elements read out loud?

- Pass: Yes, navigation works
- Fail: No or in part

</details>

<details>
<summary><strong>3.3 Localization</strong></summary>

**Why it matters:** Not all users speak English. Localization expands the audience and improves UX for non-English speakers.

**How to check:** Are languages other than English supported?

- Pass: 5+ languages
- Partial: 2–4 languages
- Fail: English only

</details>

<details>
<summary><strong>3.4 Onboarding</strong></summary>

**Why it matters:** New users may not understand how the app works. Onboarding lowers the learning curve.

**How to check:** Is there a first-launch tutorial?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.5 Help/support</strong></summary>

**Why it matters:** If something is unclear or goes wrong, the user should be able to find help easily.

**How to check:** Is there built-in help, FAQ, or quick access to support (Contact Us)?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.6 Clear warnings</strong></summary>

**Why it matters:** A good warning explains the risk and helps the user make the right decision.

**How to check:** Do warnings explain:
- What will happen (action)
- Why it matters (risk)
- What to do (recommendation)

- Pass: Yes, warnings are helpful (2+ elements)
- Fail: No, just "Are you sure?"

</details>

<details>
<summary><strong>3.7 Side-by-side comparison</strong></summary>

**Why it matters:** For visual content (photos, documents), it's convenient to compare files next to each other to pick the best one.

**How to check:** Can you compare two files from a group side by side in the interface?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.8 Sorting/grouping</strong></summary>

**Why it matters:** Sorting by size helps remove the largest duplicates first and free up space faster.

**How to check:** Can you sort results by size, date, or path? Group them?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.9 Search in results</strong></summary>

**Why it matters:** With thousands of results, you need a way to quickly find a specific file or folder.

**How to check:** Is there a search or filter field in the results?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.10 Metadata (EXIF)</strong></summary>

**Why it matters:** EXIF helps you understand which photo is more "original" — by capture date, camera, geolocation.

Use real camera photos with EXIF data.

**How to check:** Does the app display EXIF data (capture date, camera, geolocation) for these photos?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.11 Deselect All</strong></summary>

**Why it matters:** If autoselect picked the wrong files, you should be able to quickly reset and start over.

**How to check:** Is there a one-click option to clear all selections?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.12 Move instead of Delete</strong></summary>

**Why it matters:** Sometimes you may want to move duplicates to a separate folder for manual review instead of deleting them right away.

**How to check:** Is there an option to move files to a folder instead of deleting them?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.13 Replace with symlink</strong></summary>

**Why it matters:** A symlink lets you keep a file "in place" (for compatibility), but free up space — the link itself takes up almost no space.

**How to check:** Can you replace a duplicate with a symbolic link?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.14 Folder merge</strong></summary>

**Why it matters:** If two folders duplicate each other in part, it's more convenient to merge them than delete files one by one.

**How to check:** Is there a feature to merge contents of duplicate folders?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.15 Export report</strong></summary>

**Why it matters:** For documentation, auditing, or analysis in other tools, exporting results is useful.

**How to check:** Can you export results (CSV, PDF, txt)?

Format(s): _______________

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.16 Session saving</strong></summary>

**Why it matters:** Scanning can take time. If you close the app, results shouldn't be lost.

**How to check:** Close the app after scanning, reopen it. Are the results saved?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.17 Operation log</strong></summary>

**Why it matters:** A history of actions helps you understand what was deleted and recover files if needed.

**How to check:** Is there a history of removed files or an activity log?

Where to find: _______________

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.18 Add to Skip List</strong></summary>

**Why it matters:** If you see a file in the results that shouldn't be removed, it's convenient to skip it right from there.

**How to check:** Can you add a file or folder to the skip list directly from the results?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.19 Processing 200K+ files</strong></summary>

**Why it matters:** Some users have hundreds of thousands of files. The app should handle large volumes without freezing.

**How to check:** On Dataset 4 (200,000 files), is the app stable and the UI responsive?

- Pass: Yes
- Fail: No (lags, freezes)

</details>

<details>
<summary><strong>3.20 Interim results</strong></summary>

**Why it matters:** During long scans, it's convenient to see interim results and start working with them before the scan finishes.

**How to check:** During scanning, are already found duplicates displayed before completion?

- Pass: Yes
- Fail: No

</details>

<details>
<summary><strong>3.21 APFS clones</strong></summary>

APFS clones use Copy-on-Write. In this case, deleting a clone does NOT free up space. The user needs to know that.

**How to check:**

1. Create a file clone: select a file → Cmd+D (creates an APFS clone).
2. Scan the folder with the original and the clone.
3. Does the app warn that deleting the clone will NOT free up space?

- Pass: Recognizes clones + warns
- Partial: Finds them, but does not warn
- Fail: Does not recognize clones

</details>

<details>
<summary><strong>3.22 iCloud</strong></summary>

Many users store files in iCloud. The app should properly handle files that exist "in the cloud only".

**How to check:**

1. Put a file into iCloud Drive.
2. Right click → Remove Download (file remains only in the cloud)
3. Scan iCloud Drive — does the app see the evicted file?

- Pass: The app works with evicted files
- Fail: The app does not see them or downloads them automatically

</details>

---

## How we test: 7 datasets

For objective evaluation purposes, we use standardized test datasets:

| Data set | Contents | What we test |
|----------|----------|--------------|
| 1 | Duplicates and trap files (230 groups × 3 copies) | Detection accuracy |
| 2 | 200 large files (50 groups × 4 copies) | Performance on large files |
| 3 | 10,000 photos (5,000 groups × 2 copies) | Typical user scenario |
| 4 | 200,000 files (1,000 groups × 200 copies) | Stress test, stability |
| 5 | 1000 files (100 groups × 10 copies, 15 nesting levels) | Deep folder structures |
| 6 | Edge cases* | Hidden files, APFS clones, symlinks, .app bundles, unicode names, long paths |
| 7 | 1 file in 8 locations | Access to different user folders |

### Datasets used for metric calculation

- **Recall (L1.1)** is calculated on datasets DS1–DS4, where the expected number of duplicate groups is known in advance.
- **FP=0 (L1.2)** is checked on datasets DS1–DS5.
- Datasets **DS6–DS7** are used for functional checks (location access and permissions) and are not included in Recall or FP metric calculation.

### Edge cases (DS6)

Non-standard macOS scenarios where many apps fail:

- Zero-byte files
- Files with extended attributes (xattr)
- Symlinks and hardlinks
- App bundles (.app) — must be treated as single items, not folders
- Hidden files (by name `.file` and by macOS hidden flag)
- APFS clones
- Unicode characters in file names (emoji, CJK characters)
- Paths longer than 255 characters

### DS7 — folder access test

Place a test file in 8 locations:

```
~/Desktop/dup_location_test/
~/Documents/dup_location_test/
~/Downloads/dup_location_test/
~/Movies/dup_location_test/
~/Music/dup_location_test/
~/Pictures/dup_location_test/
~/Library/dup_location_test/    ← requires Full Disk Access
~/DuplicateTest/
```

**Expected result:** 1 group of 7 files. The file in ~/Library/ must be excluded from results.

### QuickTest — minimal dataset for quick evaluation

A minimal dataset (~150 MB) for fast initial testing:

```
~/DuplicateTest/
├── originals/              ← 10 original files of different types
│   ├── photo.jpg                (photo with EXIF)
│   ├── document.pdf
│   ├── video.mp4
│   ├── music.mp3
│   ├── archive.zip
│   ├── text.txt
│   ├── .hidden1.txt             (hidden file)
│   ├── .hidden2.txt             (hidden file)
│   ├── large_file.dmg           (>100 MB)
│   ├── emoji_🎉.txt             (unicode in name)
│   └── similar_name_A.txt       (TRAP — unique content)
├── copies/                 ← copies of originals
│   └── similar_name_B.txt       (TRAP — similar name, DIFFERENT content)
├── nested/                 ← deep nesting test
│   └── level1/level2/level3/photo.jpg
├── .hidden_folder_A/       ← hidden folder with files
├── .hidden_folder_B/       ← duplicate hidden folder
├── folder_dup_A/           ← regular folder
└── folder_dup_B/           ← duplicate folder
```

**Expected results:**

| What should be found | Groups | Files per group |
|---------------------|--------|----------------|
| video.mov (originals + copies + nested) | 1 | 3 |
| photo.jpg (originals + copies + nested) | 1 | 3 |
| 8 other files (originals + copies) | 8 | 2 |
| Files in hidden folders | 2 | 2 |
| Files in duplicate folders (or folders themselves) | 2 (files) or 1 (folders) | varies |
| Hidden folders as duplicate folders | 1 | 2 (folders) |
| **Total** | **15** | **32 files, 4 folders** |

**What must NOT be found:** similar_name_A.txt and similar_name_B.txt — these have different content and are not duplicates. This is a trap for apps that match by name rather than content.

**Limitations:** The QuickTest dataset does not test stability on large volumes (criterion 1.7) or precise performance baseline (criterion 2.5). Use DS2–DS4 for those.

### Downloads

- [QuickTest dataset](https://github.com/Nektony/duplicate-file-finder/releases/download/v1.0/quicktest-df.zip) (~150 MB) — minimal dataset for quick evaluation
- [Test dataset scripts](https://github.com/Nektony/duplicate-file-finder/releases/download/v1.0/scripts-df.zip) — scripts to generate datasets DS1–DS7
---

## Performance baseline

Measured on Apple Silicon + SSD. For Intel Macs, multiply by 1.5–2×.

### Scan speed

| Dataset | Excellent | Acceptable | Unacceptable |
|---------|-----------|------------|--------------|
| DS2 (large files) | < 30 sec | < 90 sec | > 180 sec |
| DS3 (10K photos) | < 60 sec | < 180 sec | > 300 sec |
| DS4 (200K files) | < 5 min | < 15 min | > 30 min |

### RAM usage

| RAM | Rating |
|-----|--------|
| < 1 GB | Excellent |
| < 2 GB | Acceptable |
| < 4 GB | Borderline |
| > 4 GB or crash | Unacceptable |

---

## Risks and common pitfalls

### Dangerous removal scenarios

| Scenario | Risk |
|----------|------|
| Photo Library | Photos.app direct removal may damage Photos.app library |
| Music Library | Same for Music.app |
| System files (~/Library/, /System/) | Risk of breaking macOS |
| Files in use | May be locked or damaged |

### False results

| Case | Problem |
|------|---------|
| APFS clones | Technically duplicates, but removal does NOT free space |
| iCloud evicted | File may auto-download during scan |
| Resource forks / xattr | Files may differ in invisible metadata |
| Sandbox limitations | App Store version sees fewer files |

### Common testing mistakes

- Compare App Store and non-App Store versions without taking into account Sandbox
- Test without Full Disk Access (incomplete results)
- Run only one scan instead of 2–3 (scan times vary)
- Not to check file recovery BEFORE bulk removal

---

## Testing protocol

### Phase P — Preparation

**Step P.1 — Set up the test environment**

1. Download test datasets (DS1–DS7) or generate using provided scripts.
2. Place datasets in ~/DuplicateTest/.
3. Set up DS7 (folder access test) as described in [DS7 — folder access test](#ds7--folder-access-test).

**Step P.2 — Set up the minimal dataset (QuickTest)**

If using QuickTest for a quick evaluation, set up ~/DuplicateTest/ as described in [QuickTest](#quicktest--minimal-dataset-for-quick-evaluation).

### Phase 0 — Initial app review

**Step 0.1 — Monetization and transparency**

| Question | Answer |
|----------|--------|
| Are free version limitations clear before you start? | Yes / No |
| Is the price visible before purchase? | Yes / No |
| Are scan results accessible without an immediate paywall? | Yes / No |
| Do ads (if any) interfere with app usage? | Yes / No / No ads |

**Step 0.2 — Interface navigation**

1. Launch the app and complete onboarding (if any).
2. Locate: folder selection, settings, scan button, results view, removal controls.

### Phase 1 — Level 1 criteria (safety)

**Goal:** Verify critical safety requirements. Failing any criterion → "Not recommended."

1. Scan ~/DuplicateTest/ with datasets DS1–DS6.
2. Test each L1 criterion as described in [Level 1 detailed descriptions](#l1-criteria--detailed-descriptions).
3. Record pass/fail for each criterion.

**If any L1 criterion fails, the app is disqualified. You may still continue testing L2/L3 for completeness.**

### Phase 2 — Level 2 criteria (functionality)

**Goal:** Evaluate functionality and usability.

Test each L2 criterion as described in [Level 2 detailed descriptions](#l2-criteria--detailed-descriptions). Record: Pass (1), Partial (0.5), or Fail (0) for each criterion.

### Phase 3 — Level 3 criteria (extras)

**Goal:** Evaluate additional features.

Test each L3 criterion as described in [Level 3 detailed descriptions](#l3-criteria--detailed-descriptions). Record: Pass (1) or Fail (0) for each criterion.

---

## Score calculation

### Formula

```
Total score = (L1 × 3) + (L2 × 2) + (L3 × 1)

Example: (7 × 3) + (18 × 2) + (15 × 1) = 21 + 36 + 15 = 72 points
```

Note: L2 criteria with partial compliance count as 0.5.

### Template

```
Level 1: ___ / 8  × 3 = ___
Level 2: ___ / 23 × 2 = ___
Level 3: ___ / 22 × 1 = ___
─────────────────────────────
TOTAL:               ___ / 92
```

### Interpretation

| Score | Recommendation |
|-------|----------------|
| 71–92 | Recommended |
| 46–70 | Recommended with caveats |
| < 46 | Not recommended |

**Disqualification:** Any L1 failure → "Not recommended" regardless of score.

### Example

```
L1: 7/8 × 3 = 21  ← one L1 failure → automatic "Not recommended"
L2: 18/23 × 2 = 36
L3: 15/22 × 1 = 15
Total: 72/92

Result: NOT RECOMMENDED (L1 failure), despite a high total score.
```

---

## Report template

### App information

| Field | Value |
|-------|-------|
| App name | |
| Version | |
| Source (App Store / website) | |
| Price / monetization model | |
| Test date | |
| macOS version | |
| Hardware (CPU, RAM, disk type) | |
| Tester | |

### Performance results

| Dataset | Scan time | RAM (peak) | Groups found | Expected | Recall |
|---------|-----------|------------|-------------|----------|--------|
| DS1 | | | | 230 | |
| DS2 | | | | 50 | |
| DS3 | | | | 5,000 | |
| DS4 | | | | 1,000 | |
| DS5 | | | | 100 | |
| DS6 | — | — | | varies | |
| DS7 | — | — | | 1 | |

### Conclusion

```
L1 blockers (if any):  ___
Main strengths:        ___
Main weaknesses:       ___
Recommendation:        Recommended / With caveats / Not recommended
```

A CSV version of this template is available in this repository: [report-template.csv](report-template.csv)

---

## FAQ

**Why do you publish the methodology if you develop a Duplicate Finder yourself?**
We believe transparency builds trust. A transparent methodology allows anyone to verify our statements. If our product is good, it will show. If not, we'll learn what needs to be improved.

**Can this methodology be used for other categories of apps?**
In part. The removal safety criteria (L1) and UX criteria (L3) apply to any cleaning utilities. The specific criteria (Photo Library, APFS clones) apply only to duplicate finders.

**Can I suggest a new criterion?**
Yes! Open an issue in this repository or email support@nektony.com. We'll consider your suggestion for the next version.

**How often is the methodology updated?**
When new macOS versions introduce relevant changes or when gaps in coverage are identified. All changes are tracked in git history.

---

## Disclaimer

This methodology is provided "as is" for reference only.

**Limitations:**
- Test results may vary depending on the app version, macOS version, hardware configuration, and test data.
- This methodology is not exhaustive and does not cover all possible use cases.
- Scores and recommendations are advisory in nature.

**Liability:**
- Nektony shall not be liable for decisions made based on test results using this methodology.
- The user shall be solely liable for choosing their software and for the consequences of using them.
- **It is always recommended to create backups before deleting files.**

**Conflict of interests:**
Nektony develops [Duplicate File Finder](https://nektony.com/duplicate-finder-remover) — an app in the tested category. We publish this methodology transparently and apply it to our own products. Independent verification of results is welcome.

---

## License

**Creative Commons Attribution 4.0 (CC BY 4.0)**

Free to copy, redistribute, adapt, create derivative works, use commercially. Attribution required.

> "Methodology for Evaluating Duplicate Finder Apps for macOS" © Nektony, 2026

---

*Methodology version: 1.1 | Last updated: March 2026*
*Interactive calculator: [nektony.com/resources/duplicate-finder-calculator](https://nektony.com/resources/duplicate-finder-calculator)*
