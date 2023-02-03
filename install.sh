#!/bin/sh

get_input() {
    echo "$1"
    read
    returnvalue=${REPLY}
}

#get_input "Enter your region:"
#region=$returnvalue
#get_input "Enter your city:"
#city=$returnvalue
#get_input "Enter your locale:"
#locale=$returnvalue
region="Europe"
city="Brussels"
locale="en_NZ"
get_input "Enter your hostname:"
hostname=$returnvalue
#get_input "Enter your username:"
#username=$returnvalue
username=norpie
get_input "Enter your password:"
password=$returnvalue

prepare() {
    sed 's/#ParallelDownloads\ =\ 5/ParallelDownloads\ =\ 15/g' /etc/pacman.conf -i
}

selecting() {
    echo "Enter your drive devices without '/dev/' (eg. sda): "
    read
    TARGET=${REPLY}
    TARGET_DEVICE="/dev/$TARGET"
}
partition() {
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
        y # confirm removal of signature
        w # save
        y # confirm removal of signature
        y # confirm removal of signature
EOF
}

formatting() {
    [[ "$TARGET_DEVICE" == *"nvme"* ]] && NVME="p"
    # Encrypt
    cryptsetup luksFormat "$TARGET_DEVICE"2
    cryptsetup open "$TARGET_DEVICE"2 cryptlvm
    # Create volumes
    pvcreate /dev/mapper/cryptlvm
    vgcreate vg1 /dev/mapper/cryptlvm
    lvcreate -L 8G vg1 -n swap
    lvcreate -L 32G vg1 -n root
    lvcreate -l 100%FREE vg1 -n home
    # Format
    mkfs.vfat -F32 "$TARGET_DEVICE"$NVME"1"
    mkfs.ext4 /dev/vg1/root
    mkfs.ext4 /dev/vg1/home
    # Swap
    mkswap /dev/vg1/swap
}

mounting() {
    [[ "$TARGET_DEVICE" == *"nvme"* ]] && NVME="p"
    # Mount Partitions
    mount /dev/vg1/root /mnt
    mount --mkdir /dev/vg1/home /mnt/home
    mkdir -p "/mnt/boot"
    mount "$TARGET_DEVICE"$NVME"1" "/mnt/boot"
    swapon /dev/vg1/swap
}

basing() {
    # Install base system
    pacstrap /mnt base base-devel linux linux-firmware lvm2
}

fstabing() {
    # Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab
}

chrooting() {
    # Copy chroot nabs into the env
    cp chroot.sh /mnt/chroot.sh &&
    # Enter chroot
    #echo "$region" "$city" "$locale" "$hostname" "$username" "$password" &&
    arch-chroot /mnt ./chroot.sh "$region" "$city" "$locale" "$hostname" "$username" "$password" &&
    # Remove the chroot.sh file
    rm /mnt/chroot.sh
}

unmounting() {
    swapoff -a
    umount /mnt -R
    umount /mnt -l
}

prepare && selecting && partition && formatting && mounting && basing && fstabing #&& chrooting && unmounting
