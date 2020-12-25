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
    +30G # confirm last sector
    y # confirm removal of signature
    n # create new partition
      # confirm number 3
      # confirm first sector
      # confirm last sector
    y # confirm removal of signature
    y # random removal sometimes
    w # save
EOF

# Format Partitions
for partition in $(lsblk --raw | grep "part" | grep "$TARGET" | awk '{print $1}' | sort); do
    partition_number="${partition: -1}"
    if [ $partition_number -eq 1 ];then
        mkfs.fat -F32 /dev/$partition
    else
        mkfs.ext4 /dev/$partition
    fi
done

# Mount Partitions
for partition in $(lsblk --raw | grep "part" | grep "$TARGET" | awk '{print $1}' | sort -r); do
    partition_number="${partition: -1}"
    if [ $partition_number -eq 3 ]; then
        mount /dev/$partition /mnt
        mkdir /mnt/boot
        mkdir /mnt/home
    elif [ $partition_number -eq 2 ]; then
        mount /dev/$partition /mnt/home
    elif [ $partition_number -eq 1 ]; then
        mount /dev/$partition /mnt/boot
    fi
done

# Install base system
basestrap /mnt base base-devel runit elogind-runit linux linux-firmware

# Generate fstab
fstabgen =U /mnt >> /mnt/etc/fstab

# Enter chroot
artools-chroot /mnt
