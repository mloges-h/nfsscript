#!/bin/bash

NFS_MOTHER_SERVER="172.16.10.50"
NFS_BASE_PATH="/nfs"

read -p "Enter NFS directory name (already created on mother server): " NFS_DIR_NAME
read -p "Enter mount directory name under /opt: " OPT_DIR_NAME

echo "----------------------------------"
echo "Checking NFS common package..."
echo "----------------------------------"

# Check & install nfs-common
if ! dpkg -l | grep -qw nfs-common; then
    echo "📦 nfs-common not found. Installing..."
    apt update -y && apt install -y nfs-common
else
    echo "✅ nfs-common already installed"
fi

echo "----------------------------------"

# Create mount directory
mkdir -p /opt/$OPT_DIR_NAME

# Mount NFS
mount -t nfs $NFS_MOTHER_SERVER:$NFS_BASE_PATH/$NFS_DIR_NAME /opt/$OPT_DIR_NAME

# Verify mount
if mount | grep -q "/opt/$OPT_DIR_NAME"; then
    echo "✅ NFS mounted successfully at /opt/$OPT_DIR_NAME"
else
    echo "❌ NFS mount failed"
    exit 1
fi
