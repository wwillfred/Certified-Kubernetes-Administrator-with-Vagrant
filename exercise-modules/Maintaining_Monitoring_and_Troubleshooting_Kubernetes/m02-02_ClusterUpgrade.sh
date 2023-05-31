/Users/verabernanski/Documents/Pluralsight/Certified_Kubernetes_Administrator/exercise-modules/Maintaining_Monitoring_and_Troubleshooting_Kubernetes m02-02 ClusterUpgrade

vagrant ssh c1-cp1

cd /vagrant/declarative-config-files/Maintaining_Monitoring_and_Troubleshooting_Kubernetes/02_Maintaining_Kubernetes_Clusters

# 1 - Find the version you want to upgrade to.
# You can only upgrade one minor version to the next minor version
sudo apt update
apt-cache policy kubeadm

# What version are we on? #--short has been deprecated, you can remove this parameter
#   if needed.
kubectl version --short
kubectl get nodes

# First, upgrade kubeadm on the Control Plane Node
# Replace the version with the version you want to upgrade to.
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.27.2-00
sudo apt-mark hold kubeadm

# All good?
kubeadm version

# Next, Drain any workload on the Control Plane Node
kubectl drain c1-cp1 --ignore-daemonsets

# Run upgrade plan to test the upgrade process and run pre-flight checks
# Highlights additional work needed after the upgrade, such as manually updating the
#   kubelets
# And displays version information for the Control Plane components
sudo kubeadm upgrade plan v1.27.2

# Run the upgrade, you can get this from the previous output.
# Runs preflight checks - API available, Node status Ready and Control Plane
#   healthy
# Checks to ensure you're upgrading along the correct upgrade path
# Prepulls container images to reduce downtime of Control Plane components
# For each Control Plane component,
#	Updates the certificates used for authentication
#	Creates a new static Pod manifest in /etc/kubernetes/manifests and saves
#	   the old one to /etc/kubernetes/tmp
#	Which causes the kubelet to restart the Pods
# Updates the Control Plane Node's kubelet configuration and also updates
#   CoreDNS and kube-proxy
sudo kubeadm upgrade apply v1.27.2  #<---this format is different than the package's version format

# Look for [upgrade/successful SUCCESS! Your cluster was upgraded to "v1.xx.yy". Enjoy!

# Uncordon the node
kubectl uncordon c1-cp1

# Now update the kubelet and kubectl on the Control Plane Node(s)
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=1.27.2-00 kubectl=1.27.2-00
sudo apt-mark hold kubelet kubectl

# Check the update status
kubectl version
kubectl get nodes

# Upgrade any additional Control Plane Nodes with the same process.


# Upgrade the workers, drain the Node, then log into it.
# Update the environment variable so you can reuse this code over and over.
NODE=node1

kubectl drain c1-$NODE --ignore-daemonsets
exit
vagrant ssh c1-node[XX]

# First, upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.27.2-00
sudo apt-mark hold kubeadm

# Updates kubelet configuration for the Node
sudo kubeadm upgrade node

# Update the kubelet and kubectl on the Node
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=1.27.2-00 kubectl=1.27.2-00
sudo apt-mark hold kubelet kubectl

# Log out of the Node
exit
vagrant ssh c1-cp1

# Get the Nodes to show the version...can take a second to update
kubectl get nodes

# Uncordon the Node to allow workload again
kubectl uncordon c1-node[XX]

# Check the versions of the Nodes
kubectl get nodes

####TO DO###
####BE SURE TO UPGRADE THE REMAINING WORKER NODES#####

# Check the versions of the Nodes
kubectl get nodes
