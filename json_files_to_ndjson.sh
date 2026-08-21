#!/usr/bin/env bash
set -euo pipefail

usage() {
   echo "Usage: $0 <input_dir> <output_ndjson_file>" >&2
   exit 1
}

[ $# -eq 2 ] || usage

input_dir=$1
output_file=$2
skipped_log="${output_file}.skipped"
error_log="${output_file}.errors"

[ -d "$input_dir" ] || { echo "Not a directory: $input_dir" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required but not found in PATH" >&2; exit 1; }

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

# Sort by the epoch-ms timestamp embedded as the trailing filename field.
# Plain filename/glob order is lexicographic, not chronological: frame
# numbers like ..._1_, ..._10_, ..._100_, ..._1000_ interleave out of order.
# The fixed-width (13-digit) epoch-ms suffix sorts correctly instead.
# (Assumes filenames contain no spaces/tabs/newlines).
: > "$work_dir/index"
for file in "$input_dir"/*.json; do
   [ -e "$file" ] || continue
   base=$(basename "$file" .json)
   printf '%s\t%s\n' "${base##*_}" "$file" >> "$work_dir/index"
done

total=$(wc -l < "$work_dir/index" | tr -d ' ')
if [ "$total" -eq 0 ]; then
   echo "No .json files found in $input_dir" >&2
   exit 1
fi

sort -n -k1,1 "$work_dir/index" | cut -f2- > "$work_dir/ordered_files"

: > "$output_file"
: > "$error_log"
: > "$skipped_log"
skipped=0
while IFS= read -r file; do
   if line=$(jq -c '.' "$file" 2>>"$error_log"); then
      printf '%s\n' "$line" >> "$output_file"
   else
      echo "$file" >> "$skipped_log"
      skipped=$((skipped + 1))
   fi
done < "$work_dir/ordered_files"

written=$(wc -l < "$output_file" | tr -d ' ')

if [ "$skipped" -eq 0 ]; then
   rm -f "$skipped_log" "$error_log"
fi

echo "Sorted $total files by embedded timestamp; wrote $written NDJSON records to $output_file ($skipped skipped)" >&2
if [ "$skipped" -gt 0 ]; then
   echo "Skipped file list: $skipped_log ; jq errors: $error_log" >&2
fi
