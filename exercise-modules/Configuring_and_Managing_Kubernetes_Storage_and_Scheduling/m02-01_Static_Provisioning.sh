# m02-01 Static provisioning

# Demo 0 - NFS Server Overview
vagrant ssh c1-storage

# More details available here: https://help.ubuntu.com/lts/serverguide/network-file-system.html
# Install NFS Server and create the directory for our exports
sudo apt install nfs-kernel-server
sudo mkdir /export
sudo mkdir /export/volumes
sudo mkdir /export/volumes/pod

# Configure our NFS Export in /etc/export for /export/volumes. Using no_root_squash
# and no_subtree_check to allow applications to mount subdirectories of the export
# directly.
sudo bash -c 'echo "/export/volumes  *(rw,no_root_squash,no_subtree_check)" > /etc/exports'
cat /etc/exports
sudo systemctl restart nfs-kernel-server.service
exit

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/02_Configuring_and_Managing_Storage_in_Kubernetes
