#!/bin/bash

# filter_existing_dirs filters the given arguments to only return directories that exist
# Supports Go-style patterns like ./cmd/... (strips /... suffix for the check)
# Usage: dirs=$(filter_existing_dirs ./cmd/... ./pkg/... ./test ./api)
filter_existing_dirs() {
    local existing=()
    for dir in "$@"; do
        # Strip Go's /... suffix if present for the directory check
        local check_dir="${dir%/...}"
        if [ -d "$check_dir" ]; then
            existing+=("$dir")
        fi
    done
    echo "${existing[@]}"
}