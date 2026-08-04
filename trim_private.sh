#!/usr/bin/env bash

# Go to chezmoi source directory
cd "$(chezmoi source-path)" || exit 1

# Rename private_* files and directories recursively
find . -depth -name "private_*" | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    new_base="${base#private_}"

    mv "$file" "$dir/$new_base"
    echo "$base -> $new_base"
done
