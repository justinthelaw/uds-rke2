#!/bin/bash
set -e

# Function to check mount point and print remaining space
check_mount() {
    if [ -d "$MOUNT_POINT" ]; then
        remaining_space=$(df -h "$MOUNT_POINT" | awk 'NR==2 {print $4}')
        echo "Mount Point: $MOUNT_POINT, Remaining Space: $remaining_space"
    else
        echo "Mount Point $MOUNT_POINT does not exist"
    fi
}

# Check if mount points were provided as an argument
if [ -z "$MOUNT_POINTS" ]; then
    echo "Usage: MOUNT_POINTS=\"/opt/ /dev/\" $0"
    exit 1
fi

# Split the mount points string into an array
IFS=' ' read -ra MOUNT_POINTS_ARRAY <<<"$MOUNT_POINTS"

# Loop through each mount point and check it
for MOUNT_POINT in "${MOUNT_POINTS_ARRAY[@]}"; do
    if [ -n "$MOUNT_POINT" ]; then
        check_mount "$MOUNT_POINT"
    fi
done
