#!/bin/bash

# Default values
PATH_TO_SHOW=""
DO_DF=false
DO_CLEAN=false

# Function to display usage
usage() {
    echo "Usage: $0 [-h|--help] [--show <path>] [--df] [--clean]"
    echo "  -h, --help    : Display this help message."
    echo "  --show <path> : Show information about a specific path."
    echo "  --df          : Display disk free space."
    echo "  --clean       : Perform a cleaning operation."
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --show)
            if [ -n "$2" ]; then
                PATH_TO_SHOW="$2"
                shift
            else
                echo "Error: --show requires a path."
                usage
            fi
            ;;
        --df)
            DO_DF=true
            ;;
        --clean)
            DO_CLEAN=true
            ;;
        *)
            echo "Unknown parameter: $1"
            usage
            ;;
    esac
    shift
done

# --- Main Logic ---

if [ -n "$PATH_TO_SHOW" ]; then
    echo "Showing information for path: $PATH_TO_SHOW"
    find "$PATH_TO_SHOW" -mindepth 1 -maxdepth 1 -exec du -sh {} + | sort -h
fi

if "$DO_DF"; then
    echo "Displaying disk free space ordered by %use:"
    (df -h | head -n 1; df -h | tail -n +2 | sort -k5 -hr)
fi

if "$DO_CLEAN"; then

    cat <<EOF
Solutions for cleaning include:

## Docker
docker system df
docker system prune
docker image prune

## Rust
find /path/to/folder -type d -name target -exec rm -r {} +
EOF
fi

if [ -z "$PATH_TO_SHOW" ] && ! "$DO_DF" && ! "$DO_CLEAN"; then
    echo "No options provided. Please specify --show, --df, or --clean."
    usage
fi
