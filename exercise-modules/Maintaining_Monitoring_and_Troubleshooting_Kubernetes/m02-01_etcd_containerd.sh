m02-01 etcd containerd

vagrant ssh c1-cp1

cd /vagrant/declarative-config-files/Maintaining_Monitoring_and_Troubleshooting_Kubernetes/02_Maintaining_Kubernetes_Clusters

# Note: this restore process is for a locally hosted etcd running in a static Pod.

# Check out some of the key etcd configuration information
# Container image and tag, command, --data dir, and mounts and volumes for both etcd-certs
#   and etcd-data
kubectl describe pod etcd-c1-cp1 -n kube-system

# The configuration for etcd comes from the static Pod manifest, check out the 
#   listen-client-urls, data-dir, volumeMounts, volumes/
sudo more /etc/kubernetes/manifests/etcd.yaml

# You can get the runtime values from ps -aux
ps -aux | grep etcd

# Let's get etcdctl on our local system here...by downloading it from github.
# TODO: Update RELEASE to match your release version!!!
# We can find out the version of etcd we're running by using etcd --version inside the
#   etcd Pod.
kubectl exec -it etcd-c1-cp1 -n kube-system \
    -- /bin/sh -c 'ETCDCTL_API=3 /usr/local/bin/etcd --version' | head
export RELEASE="3.5.3"
wget https://github.com/etcd-io/etcd/releases/download/v${RELEASE}/etcd-v${RELEASE}-linux-amd6
4.tar.gz
tar -zxvf etcd-v${RELEASE}-linux-amd64.tar.gz
cd etcd-v${RELEASE}-linux-amd64
sudo cp etcdctl /usr/local/bin

# Quick check to see if we have etcdctl...
ETCDCTL_API=3 etcdctl --help | head

# First, let's create a secret that we're going to delete and then get back when we run the
#   restore.
kubectl create secret generic test-secret \
    --from-literal=username='svcaccount' \
    --from-literal=password='S0mthingS0Str0ng!'

# Define a variable for the endpoint to etcd
ENDPOINT=https://127.0.0.1:2379

# Verify we're connecting to the right cluster...define your endpoints and keys
sudo ETDCTL_API=3 etcdctl --endpoints=$ENDPOINT \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    member list

# Take the backup, saving it to /var/lib/dat-backup.db...
# Be sure to copy that to remote storage when doing this for real
sudo ETCDCTL_API=3 etcdctl --endpoints=$ENDPOINT \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /var/lib/dat-backup.db

# Read the metadata from the backup/snapshot to print out the snapshot's status
sudo ETCDCTL_API=3 etcdctl --write-out=table snapshot status /var/lib/dat-backup.db
