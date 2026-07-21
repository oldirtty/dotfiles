#!/usr/bin/env bash
# Usage: ./getsubs_folder.sh <folder> [extension]

if [ -z "$1" ]; then
    echo "Usage: $0 <folder> [extension]"
    echo "  extension: file extension to match (default: mkv)"
    exit 1
fi

FOLDER="$1"
EXT="${2:-mkv}"
EXT="${EXT#.}"

if [ ! -d "$FOLDER" ]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

# Ask credentials once
read -r -p "OpenSubtitles username: " USER
read -r -s -p "OpenSubtitles password: " PASS
echo ""

cd "$FOLDER" || exit 1

for ep in *."$EXT"; do
    [ -e "$ep" ] || { echo "No .$EXT files found in '$FOLDER'."; break; }

    base="${ep%.*}"

    if [ -f "${base}.srt" ]; then
        echo "==> Subtitle already exists: ${base}.srt"
        read -r -p "    Override? [y/N] " answer
        case "$answer" in
            [yY]) ;;
            *) echo "    Skipping."; continue ;;
        esac
    fi

    echo "==> Processing: $ep"
    output=$(OpenSubtitlesDownload.py "$ep" -l pt-br -u "$USER" -p "$PASS" --cli -t auto 2>&1)
    exit_code=$?
    echo "$output" | head -25

    if echo "$output" | grep -qiE "406|download quota|out of downloads|download limit"; then
        echo ""
        echo "!! Download limit reached. Stopping."
        exit 1
    fi

    echo ""
done