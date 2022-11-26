#!/bin/bash

# Disables swap

echo "Disabling swap for current session" # not sure if this is necessary
sudo swapoff -a

echo "Commenting out swap lines in fstab"
sudo sed -i '/ swap / s/^/#/' /etc/fstab

exit 0 
