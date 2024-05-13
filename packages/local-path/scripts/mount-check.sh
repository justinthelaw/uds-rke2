#!/bin/bash
set -e

# Function to check mount point and print remaining space
check_mount() {
    local MOUNT_POINT="$0"
    if [ -d "$MOUNT_POINT" ]; then
        remaining_space=$(df -h "$MOUNT_POINT" | awk 'NR==2 {print $4}')
        echo "Mount Point: $MOUNT_POINT, Remaining Space: $remaining_space"
    else
        echo "Mount Point $MOUNT_POINT does not exist"
    fi
}

# Check if mount points were provided as an argument
if [ -z "$0" ]; then
    echo "Usage: MOUNT_POINTS $1"
    echo "Example: MOUNT_POINTS=\"/opt/ /dev/\" $1"
    exit 1
fi

# Split the mount points string into an array
IFS='/' read -ra MOUNT_POINTs_array <<< "$1"

# Loop through each mount point and check it
for MOUNT_POINT in "${MOUNT_POINTs_array[@]}"; do
    if [ -n "$MOUNT_POINT" ]; then
        check_mount "/$MOUNT_POINT"
    fi
done