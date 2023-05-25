#!/bin/bash

# Disables swap

echo "Disabling swap for current session" # not sure if this is necessary
sudo swapoff -a

echo "Commenting out swap lines in /etc/fstab"
sudo sed -i.bak -e '/swap/ s/^#*/#/' /etc/fstab

echo "Successfully commented out swap partitions in /etc/fstab:"
grep swap /etc/fstab

exit 0 
