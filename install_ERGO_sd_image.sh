#!/bin/bash


IMG_NAME="2015-05-05-raspbian-wheezy.img"
CURRENT_USER=$(whoami) 
IMG_MOUNT_PATH="/media/$CURRENT_USER/13d368bf-6dbf-4751-8ba1-88bed06bef77/"
UNIT_ID_PATH="/etc/ERGO/UNIT_ID"
UNIT_ID_FILE_NAME="./current_UNIT_ID"
DEFAULT_PASSWORD=""
UNIT_ID=""

select_disks ()
{
sudo parted -l  2>&1  |grep "Disk /"


read -p "What is the name of the card you want to burn to? Example: sdd : "  DISK_ID

DISK_INFO=$("parted -l 2>&1 |grep /dev/$DISK_ID" ) 

 if [ -z "$DISK_INFO" ]
  then
   printf "No such disk please try again.\n"
   select_disks
 fi

while true; do
    read -p "Does this disk info look correct? \n $DISK_INFO \n WARNING SELECTING THE WRONG DISK CAN RESULT IN SERIOUS DAMMAGE : " yn
    case $yn in
        [Yy]* ) write_img "$DISK_ID"; break;;
        [Nn]* ) select_disks; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

config_password()
{

while true; do
	read -p "Would you like to use the default DEFAULT_PASSWORD or set your own? s for set d for default. : " sd
	case $sd in
		[Ss]* ) set_password; break;;
		[Dd]* ) set_default_password; break;;
		* ) echo "S or D only.";;
	esac
done 
}

set_custom_password()
{
read -p "What would you like the password for unit #$UNIT_ID to be?" custom_password 
set_password "$custom_password";

} 
set_password()
{

}

write_img () 
{
  if [ -z "$1" ]
   then
     return 0
   fi
   echo "Writing $IMG_NAME"
   sudo dd bs=1M if=./$IMG_NAME | pv |sudo dd of=/dev/"$1" ;sync
 
}

mount_img()
{

gnome-disk-image-mounter -w $IMG_NAME 

}

write_id ()
{
if [ -z "$1" ]
then
  return 0
fi
UNIT_ID="$1"
UNIT_ID_PATH=$("$IMG_MOUNT_PATH$UNIT_ID_PATH")
echo "$UNIT_ID" |sudo tee "$UNIT_ID_PATH"

##change the hostname
CURRENT_HOSTNAME=$("cat $HOSTNAME_PATH | tr -d " \t\n\r" " )
NEW_HOSTNAME="ERGO-$UNIT_ID"
echo "$NEW_HOSTNAME" | sudo tee "$HOSTNAME_PATH" sudo sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g"  "$IMG_MOUNT_PATH/etc/hosts"
}

select_UNIT_ID ()
{
HOSTNAME_PATH="$IMG_MOUNT_PATH/etc/hostname/"

read -p "What would you like this units id to be ?" UNIT_ID
write_id "$UNIT_ID"

}

increment_UNIT_ID ()
{
HOSTNAME_PATH="$IMG_MOUNT_PATH/etc/hostname/"


if [ ! -f $UNIT_ID_FILE_NAME ]; then
  read -p "File $UNIT_ID_FILE_NAME does not exist what number would you like to start with ? " UNIT_ID
  echo "$UNIT_ID" > $UNIT_ID_FILE_NAME 
fi

UNIT_ID=$(cat "$UNIT_ID_FILE_NAME") 
write_id "$UNIT_ID"

let UNIT_ID+=1
echo $UNIT_ID |sudo tee $UNIT_ID_FILE_NAME

}


mount_img
UNIT_ID_PATH="$IMG_MOUNT_PATH$UNIT_ID_PATH"
echo "$UNIT_ID_PATH"
while true; do
    read -p "Would you like to select the unit id or increment from last unit id? S for select A for increment" sa
    case $sa in
        [Ss]* ) select_UNIT_ID; break;;
        [Aa]* ) increment_UNIT_ID; break;;
        * ) echo "Please select S or A only.";;
    esac
done
select_disks
