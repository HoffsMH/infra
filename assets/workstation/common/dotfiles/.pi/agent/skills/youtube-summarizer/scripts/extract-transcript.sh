#!/bin/bash
# extract-transcript.sh - Downloads YouTube transcript and converts to clean text
# Usage: ./extract-transcript.sh <youtube_url> [output_file]

set -e

URL="$1"
OUTPUT_FILE="${2:-transcript.txt}"

if [ -z "$URL" ]; then
    echo "Usage: $0 <youtube_url> [output_file]"
    exit 1
fi

# Create temp directory for processing
TMP_DIR=$(mktemp -d)
trap "\rm -rf $TMP_DIR" EXIT

cd "$TMP_DIR"

echo "[*] Downloading subtitles from: $URL" >&2

# Download subtitles using yt-dlp
yt-dlp --write-auto-subs --sub-lang en --skip-download --convert-subs srt \
    -o "video" "$URL" 2>&1 | grep -E "subtitles|Converting" || true

if [ ! -f video.en.srt ]; then
    echo "[!] Failed to fetch subtitles for $URL" >&2
    exit 1
fi

echo "[*] Extracting and cleaning transcript..." >&2

# Extract text from SRT, removing timestamps and sequence numbers
python3 << 'PYTHON'
import re
import sys

with open('video.en.srt', 'r') as f:
    srt_content = f.read()

lines = srt_content.split('\n')
text_lines = []

for line in lines:
    stripped = line.strip()
    # Skip empty lines, sequence numbers (all digits), and timestamp lines (contain -->)
    if stripped and not re.match(r'^\d+$', stripped) and '-->' not in stripped:
        text_lines.append(stripped)

# Join with spaces, collapsing multiple spaces
transcript = ' '.join(text_lines)
transcript = re.sub(r'\s+', ' ', transcript)

print(transcript)
PYTHON

echo "[+] Done. Transcript extracted." >&2
