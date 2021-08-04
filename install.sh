#!/bin/sh

echo "Enter your drive devices without '/dev/' (eg. sda): "
read 
TARGET=${REPLY} TARGET_DEVICE="/dev/$TARGET"

# Partitioning of the disk
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $TARGET_DEVICE 
    d # delete partition
      # confirm deletion of partition 3
    d # delete partition
      # confirm deletion of partition 2
    d # delete partition, automatically confirms partition 1
    n # create new partition
      # confirm number 1
      # confirm first sector
    +1G # confirm last sector 
    y # confirm removal of signature
    n # create new partition
      # confirm number 2
      # confirm first sector
      # confirm last sector
    y # confirm removal of signature
    w # save
EOF

# Format Partitions
mkfs.vfat -F32 "/dev/$TARGET\1"
mkfs.ext4 "/dev/$TARGET\2"

# Mount Partitions
mount "/dev/$TARGET\2" "/mnt"
mkdir -p "/mnt/boot"
mount "/dev/$TARGET\1" "/mnt/boot"

# Install base system
pacstrap /mnt base base-devel linux linux-firmware

# Generate fstab
fstabgen -U /mnt >> /mnt/etc/fstab

# Copy chroot nabs into the env
cp chroot.sh /mnt/chroot.sh

# Enter chroot
arch-chroot /mnt "chroot.sh"
