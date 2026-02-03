#!/bin/bash

# -------- VARIABLES --------
NFS_MOTHER_SERVER="172.16.10.50"
NFS_BASE_PATH="/nfs"

CURRENT_SERVER_IP=$(hostname -I | awk '{print $1}')

echo "Current Server IP detected as: $CURRENT_SERVER_IP"
echo "----------------------------------------"

# -------- STEP 1: NFS MOTHER SERVER --------
read -p "Enter directory name to create on NFS mother server (/nfs): " NFS_DIR_NAME

ssh root@$NFS_MOTHER_SERVER <<EOF
mkdir -p $NFS_BASE_PATH/$NFS_DIR_NAME

grep -q "^$NFS_BASE_PATH/$NFS_DIR_NAME" /etc/exports || \
echo "$NFS_BASE_PATH/$NFS_DIR_NAME $CURRENT_SERVER_IP(rw,sync)" >> /etc/exports

exportfs -a
EOF

echo "✅ Directory created and exported on NFS mother server"
echo "----------------------------------------"

# -------- STEP 2: CURRENT NFS COMMON SERVER --------
read -p "Enter directory name to create under /opt on current server: " OPT_DIR_NAME

mkdir -p /opt/$OPT_DIR_NAME

mount -t nfs $NFS_MOTHER_SERVER:$NFS_BASE_PATH/$NFS_DIR_NAME /opt/$OPT_DIR_NAME

if mount | grep -q "/opt/$OPT_DIR_NAME"; then
    echo "✅ NFS mounted successfully at /opt/$OPT_DIR_NAME"
else
    echo "❌ NFS mount failed"
    exit 1
fi

echo "----------------------------------------"

# -------- STEP 3: FSTAB ENTRY FOR LIVE SERVER --------
echo "📌 Add the below entry in /etc/fstab on LIVE server:"
echo ""
echo "$NFS_MOTHER_SERVER:$NFS_BASE_PATH/$NFS_DIR_NAME  /opt/$OPT_DIR_NAME  nfs  rw,sync  0  0"
echo ""
echo "After adding, run: mount -a"
