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

# On each Node in the cluster...install the NFS client.
sudo apt install nfs-common -y

# On one of the Nodes, test out basic NFS access before moving on.
vagrant ssh c1-node1
sudo mount -t nfs4 c1-storage:/export/volumes /mnt/
mount | grep nfs
sudo umount /mnt
exit


# Demo 1 - Static provisioning persistent volumes
vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/02_Configuring_and_Managing_Storage_in_Kubernetes

# Create a PV with the read/write many and retain as the reclaim policy
kubectl apply -f nfs.pv.yaml

# Review the created resources, Statuses, Access Mode and Reclaim policy is set to
# Retain rather than Delete.
kubectl get PersistentVolume pv-nfs-data

# Look more closely at the PV and its configuration
kubectl describe PersistentVolume pv-nfs-data

# Create a PVC on that PV
kubectl apply -f nfs.pvc.yaml

# Check the status, now it's Bound due to the PVC on the PV. See the claim...
kubectl get PersistentVolume

# Check the status, Bound.
# We defined the PVC it statically provisioned the PV...but it's not mounted yet.
kubectl get PersistentVolumeClaim pvc-nfs-data
kubectl describe PersistentVolumeClaim pvc-nfs-data

# Let's create some content on our storage server
exit
vagrant ssh c1-storage
sudo bash -c 'echo "Hello from our NFS mount!!!" > /export/volumes/pod/demo.html'
more /export/volumes/pod/demo.html
exit


# Let's create a Pod (in a Deployment and add a Service) with a PVC on pvc-nfs-data
vagrant ssh c1-cp1
kubectl apply -f nfs.nginx.yaml
kubectl get service nginx-nfs-service
SERVICEIP=$(kubectl get service | grep nginx-nfs-service | awk '{ print $3 }')

# Check to see if our pods are Running before proceeding
kubectl get pods

# Let's access that application to see our application data...
curl http://$SERVICEIP/web-app/demo.html
