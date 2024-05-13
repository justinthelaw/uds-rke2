#!/bin/bash
set -e

# Function to check mount point and print remaining space
check_mount() {
    local mount_point="$1"
    if [ -d "$mount_point" ]; then
        remaining_space=$(df -h "$mount_point" | awk 'NR==2 {print $4}')
        echo "Mount Point: $mount_point, Remaining Space: $remaining_space"
    else
        echo "Mount Point $mount_point does not exist"
    fi
}

# Check if mount points were provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 MOUNT_POINTS"
    echo "Example: MOUNT_POINTS=\"/opt/ /dev/\" $0"
    exit 1
fi

# Split the mount points string into an array
IFS='/' read -ra mount_points_array <<< "$1"

# Loop through each mount point and check it
for mount_point in "${mount_points_array[@]}"; do
    if [ -n "$mount_point" ]; then
        check_mount "/$mount_point"
    fi
done