#!/usr/bin/env bash
#
# html2xhtml.sh — convert a single HTML file, or every HTML file in a
# directory, to well-formed XHTML using xmllint.
#
# Usage:
#   html2xhtml.sh [-o output_dir] [-f] <file_or_directory>
#
#   -o output_dir   Write converted files here instead of next to the
#                    originals. Directory structure is preserved when
#                    converting a directory.
#   -f               Overwrite existing .xhtml output files.
#
# Examples:
#   html2xhtml.sh page.html
#   html2xhtml.sh -o build/xhtml site/
#   html2xhtml.sh -f -o out ./html_dir

set -euo pipefail

usage() {
    grep '^#' "$0" | sed '1d;s/^# \{0,1\}//'
    exit "${1:-0}"
}

OUTPUT_DIR=""
FORCE=0

while getopts ":o:fh" opt; do
    case "$opt" in
        o) OUTPUT_DIR="$OPTARG" ;;
        f) FORCE=1 ;;
        h) usage 0 ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage 1 ;;
        :) echo "Option -$OPTARG requires an argument" >&2; usage 1 ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -ne 1 ]]; then
    echo "Error: expected exactly one argument (file or directory)" >&2
    usage 1
fi

INPUT="$1"

if ! command -v xmllint >/dev/null 2>&1; then
    echo "Error: xmllint is not installed or not on PATH" >&2
    exit 1
fi

if [[ ! -e "$INPUT" ]]; then
    echo "Error: '$INPUT' does not exist" >&2
    exit 1
fi

convert_file() {
    local src="$1" dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
        echo "Skip (exists): $dest"
        return 0
    fi

    if xmllint --html --xmlout --nowarning --output "$dest" "$src" 2>/tmp/html2xhtml.err; then
        echo "Converted: $src -> $dest"
    else
        echo "Failed: $src" >&2
        cat /tmp/html2xhtml.err >&2
        rm -f /tmp/html2xhtml.err
        return 1
    fi
    rm -f /tmp/html2xhtml.err
}

dest_for() {
    # dest_for <src> <base_dir>
    local src="$1" base="$2"
    local rel out
    if [[ -n "$OUTPUT_DIR" ]]; then
        rel="${src#"$base"/}"
        out="$OUTPUT_DIR/${rel%.*}.xhtml"
    else
        out="${src%.*}.xhtml"
    fi
    echo "$out"
}

FAIL_COUNT=0

if [[ -f "$INPUT" ]]; then
    if [[ -n "$OUTPUT_DIR" ]]; then
        DEST="$OUTPUT_DIR/$(basename "${INPUT%.*}").xhtml"
    else
        DEST="${INPUT%.*}.xhtml"
    fi
    convert_file "$INPUT" "$DEST" || FAIL_COUNT=$((FAIL_COUNT + 1))

elif [[ -d "$INPUT" ]]; then
    BASE_DIR="${INPUT%/}"
    while IFS= read -r -d '' file; do
        DEST="$(dest_for "$file" "$BASE_DIR")"
        convert_file "$file" "$DEST" || FAIL_COUNT=$((FAIL_COUNT + 1))
    done < <(find "$BASE_DIR" -type f \( -iname '*.html' -o -iname '*.htm' \) -print0)

else
    echo "Error: '$INPUT' is neither a regular file nor a directory" >&2
    exit 1
fi

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo "Done with $FAIL_COUNT failure(s)." >&2
    exit 1
fi

echo "Done."
