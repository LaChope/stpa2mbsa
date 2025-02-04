#!/bin/bash
# txtttl2ann.sh
# Usage: ./txtttl2ann.sh <scenario.txt> <scenario.ttl>
#
# This script takes two inputs:
#   - A .txt file containing the scenario in the following form:
#
#       (LS-3.1)
#       Control Desk provides the Querry Mission Data action too late
#       - Control Desk received feedback (or other inputs) that indicated too late when the mission has already started on time
#
#   - A .ttl file (here used for canonical values if desired)
#
# It produces a Brat annotation file (.ann) with four annotations:
#   T1	stpa_LossScenario
#   T2	stpa_Controller
#   T3	stpa_ControlAction
#   T4	stpa_Context
#
# The script normalizes the text and then computes the character offsets
# for each entity, ensuring that the annotation text matches exactly the
# text in the normalized full text.

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <scenario.txt> <scenario.ttl>"
  exit 1
fi

txt_file="$1"
ttl_file="$2"

if [ ! -f "$txt_file" ]; then
  echo "Text file '$txt_file' not found!"
  exit 1
fi

if [ ! -f "$ttl_file" ]; then
  echo "TTL file '$ttl_file' not found!"
  exit 1
fi

# --- 1. Read and normalize the text ---
# We assume the .txt file has three lines.
line1=$(sed -n '1p' "$txt_file")
line2=$(sed -n '2p' "$txt_file")
line3=$(sed -n '3p' "$txt_file")

# Normalize line1 by:
# - Removing parentheses
# - Trimming spaces
# - Replacing dashes with underscores so that the displayed text matches the annotation text.
norm_line1=$(echo "$line1" | sed 's/[()]//g' | sed 's/^[ \t]*//; s/[ \t]*$//' | sed 's/-/_/g')
# Use norm_line1 as T1.
T1="$norm_line1"

# Normalize line2 (trim leading/trailing spaces)
norm_line2=$(echo "$line2" | sed 's/^[ \t]*//; s/[ \t]*$//')

# Normalize line3 by removing a leading "- " and trimming spaces.
norm_line3=$(echo "$line3" | sed 's/^- *//; s/^[ \t]*//; s/[ \t]*$//')

# Reassemble the normalized full text.
# (Note: newline characters are preserved.)
full_text_norm="${norm_line1}"$'\n'"${norm_line2}"$'\n'"${norm_line3}"

# --- 2. Extract entity mention texts ---
# T2: from line2, extract everything before " provides"
T2=$(echo "$norm_line2" | sed -n 's/^\(.*\) provides.*/\1/p')
T2=$(echo "$T2" | sed 's/^[ \t]*//; s/[ \t]*$//')

# T3: from line2, extract between "provides the " and " action"
T3=$(echo "$norm_line2" | sed -n 's/.*provides the \(.*\) action.*/\1/p')
T3=$(echo "$T3" | sed 's/^[ \t]*//; s/[ \t]*$//')

# T4: from line3, extract the substring after "that indicated"
# First, try to match "that indicated too late " (case‐insensitive),
# otherwise match "that indicated ".
if echo "$norm_line3" | grep -qi "that indicated too late "; then
  T4=$(echo "$norm_line3" | sed -n 's/.*[Tt]hat indicated too late[ ]*\(.*\)$/\1/p')
elif echo "$norm_line3" | grep -qi "that indicated "; then
  T4=$(echo "$norm_line3" | sed -n 's/.*[Tt]hat indicated[ ]*\(.*\)$/\1/p')
fi
# Optionally, remove a leading "when " if present.
T4=$(echo "$T4" | sed -e 's/^[Ww]hen[ ]*//')

# --- 3. Compute offsets in the normalized full text ---
# We use awk’s index() function, which returns a 1-indexed position.
get_offset() {
  # Usage: get_offset "<needle>"
  awk -v hay="$full_text_norm" -v needle="$1" 'BEGIN { pos = index(hay, needle); if(pos==0) { print -1 } else { print pos - 1 } }'
}

offset_T1=$(get_offset "$T1")
offset_T2=$(get_offset "$T2")
offset_T3=$(get_offset "$T3")
offset_T4=$(get_offset "$T4")

# Check that no offset is negative.
if [ "$offset_T1" -lt 0 ] || [ "$offset_T2" -lt 0 ] || [ "$offset_T3" -lt 0 ] || [ "$offset_T4" -lt 0 ]; then
  echo "Error: One or more offsets could not be found in the normalized text."
  echo "Offsets computed: T1=$offset_T1, T2=$offset_T2, T3=$offset_T3, T4=$offset_T4"
  exit 1
fi

# Get lengths of each entity
len_T1=${#T1}
len_T2=${#T2}
len_T3=${#T3}
len_T4=${#T4}

# --- 4. Write the annotation file ---
# The .ann file will have the same base name as the text file.
ann_file="${txt_file%.txt}.ann"

{
  echo "T1	stpa_LossScenario $offset_T1 $((offset_T1 + len_T1))	$T1"
  echo "T2	stpa_Controller $offset_T2 $((offset_T2 + len_T2))	$T2"
  echo "T3	stpa_ControlAction $offset_T3 $((offset_T3 + len_T3))	$T3"
  echo "T4	stpa_Context $offset_T4 $((offset_T4 + len_T4))	$T4"
} > "$ann_file"

echo "Generated annotation file: $ann_file"
