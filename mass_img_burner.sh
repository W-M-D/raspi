#!/bin/bash


IMG_NAME="2016-02-26-raspbian-jessie.img"
CURRENT_USER=$(whoami) 
UNIT_ID=""
DISK_INFO=""
DISK_PATHS=""

select_disks ()
{

DISK_INFO=$(parted -l 2>&1 |grep -Po "Disk\s(\/dev\/sd[^abc])\:\s\d+GB") 
DISK_PATHS=$(echo $DISK_INFO |grep -Po "(\/dev\/sd[^abc])")
NUM_DISKS=$(echo "$DISK_INFO" | wc -l)

if [ -z "$DISK_INFO" ]
 then
  printf "No disks please try again.\n"
  exit 1
fi

while true; do
    perl -e 'print "*"x50;print "\n"'
    echo "$DISK_INFO"
    perl -e 'print "*"x50;print "\n\n"'
    read -p "There are $NUM_DISKS ready. Do these disks look correct?  WARNING SELECTING THE WRONG DISKS CAN RESULT IN SERIOUS DAMMAGE : " yn
    case $yn in
        [Yy]* ) write_img; break;;
        [Nn]* ) select_disks; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

}

write_img ()
{
for $PATH in $DISK_PATHS;
do ( dd bs=1M status=progress if=/dev/zero of=$PATH && dd bs=1M if=$IMG_NAME of=$PATH; ) &  
done
}

select_disks
