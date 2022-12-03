# m03.sh

## Installing and Configuring containerd

### 0 - Install packages

# ssh into c1-cp1
vagrant ssh c1-cp1

# containerd prerequisites, first load two modules and configure them to load on boot
# https://kubernetes.io.docs/setup/production-environment/container-runtimes/
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Setup required sysctl params, these persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd

# Create a containerd configuration file
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Set the cgroup driver for containerd to systemd which is required for the kubelet
# For more information on this config file see:
# https://github.com/containerd/cri/blob/master/docs/config.md and also
# https://github.com/containerd/containerd/blob/master/docs/ops.md

# Change SystemdCgroup = false to SystemdCgroup = true
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Verify the change was ade
sudo vi /etc/containerd/config.toml

# Restart containerd with the new configuration
sudo systemctl restart containerd

# Install Kubernetes packages - kudeadm, kubelet and kubectl
# Add Google's apt repository gpg key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the package list and use apt-cache policy to inspect versions available in the repository
sudo apt-get update
apt-cache policy kubelet | head -n 20

#Install the required packages, if needed we can request a specific version.
#Use this version because in a later course we will upgrade the cluster to a newer version.
#Try to pick one version back because later in this series, we'll run an upgrade
VERSION=1.24.3-00
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl containerd

#To install the latest, omit the version parameters
#sudo apt-get install kubelet kubeadm kubectl
#sudo apt-mark hold kubelet kubeadm kubectl containerd

### 1 - systemd Units
# Check the status of our kubelet and our container runtime, containerd.
# The kubelet will enter a crashloop until a cluster is created or the node is joined to an existing cluster.
sudo systemctl status kubelet.service
sudo systemctl status containerd.service

# Ensure both are set to start when the system starts up
sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service

## Create control plane node - containerd

###IMPORTANT###
# If you are using containerd, make sure Docker isn't installed.
# kubeadm init will try to auto-detect the container runtaime and at the moment
# if both are installed it will pick docker first.

### 0 - Create a cluster
# Create our kubernetes cluster, specify a pod network range matching that in calico.yaml!
# Only on the Control Plane Node, download the yaml files for the pod network.
wget https://docs.projectcalico.org/manifests/calico.yaml

# Look inside calico.yaml and find the setting for Pod Network IP address range CALICO_IPV4POOL_CIDR,
# adjust if needed for your infrastructure to ensure that the Pod network IP
# range doesn't overlap with other networks in our infrastructure.
vi calico.yaml

# You can now just use kubeadm init to bootstrap the cluster
sudo kubeadm init --kubernetes-version v1.24.3
# sudo kubeadm init # remove the kubernetes-version parameter if you want to use the latest.

# Before moving on, review the output of the cluster creation process including the kubeadm init phases,
# the admin.conf setup and the node join command

# Configure our account on the Control Plane Node to have admin access to the API server from a non-privileged account.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### 1 - Creating a Pod Network
# Deploy yaml file for your pod network.
kubectl apply -f calico.yaml

# Look for all the system pods and calico pods to change to Running.
# The DNS pod won't start (pending) until the Pod network is deployed and Running.
kubectl get pods --all-namespaces

# Gives you output over time, rather than repainting the screen on each iteration.
kubectl get pods --all-namespaces --watch

# Get a list of our current nodes, just the Control Plane Node node ... should be Ready
kubectl get nodes

# 2 systemd Units...again!
# Check out the systemd unit...it's no longer crashlooping because it has static pods to start
# Remember the kubelet starts the static pods, and thus the control plane pods
sudo systemctl status kubelet.service

# 3 - Status Pod manifests
# Let's check out the static pod manifests on the Control Plane Node
ls /etc/kubernetes/manifests

# And look more closely at API server and etcd's manifest.
sudo more /etc/kubernetes/manifests/etcd.yaml
sudo more /etc/kubernetes/manifests/kube-apiserver.yaml

# Check out the directory where the kubeconfig files live for each of the control plan pods.
ls /etc/kubernetes

# disconnect from c1-cp1
exit


## Create nodes - containerd

# For this demo, ssh into c1-node1
vagrant ssh c1-node1

# Disable swap, swapoff then edit your fstab removing any entry for swap partitions
# You can recover the space with fdisk. You may want to reboot to ensure your config is ok.
swapoff -a
vi /etc/fstab

###IMPORTANT####
# I expect this code to change a bit to make the installation process more streamlined.
# Overall, the end result will stay the same...you'll have continerd installed
# I will keep the code in the course downloads up to date with the latest method.
################

# 0 - Joining Nodes to a Cluster

#Install a container runtime - containerd
# containerd prerequisites, and load two modules and configure them to load on boot
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# systctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Set the cgroup driver for containerd to systemd which is required for the kubelet.
#For more information on this config file see:
# https://github.com/containerd/cri/blob/master/docs/config.md and also
# https://github.com/containerd/containerd/blob/master/docs/ops.md

#At the end of this section, change SystemdCgroup = false to SystemdCgroup = true
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
        ...
#          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true

# ... To do this, use sed to swap in true
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Verify the change was made
sudo vi /etc/containerd/config.toml

# Restart containerd with the new configuration
sudo systemctl restart containerd


# Install Kubernetes packages - kubeadm, kubelet, and kubectl
# Add Google's apt repository gpg key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the package list
sudo apt-get update
apt-cache policy kubelet | head -n 20

# Install the required packages, if needed we can request a specific version.
# Pick the same version you used on the Control Plane Node above.
VERSION=1.24.3-00
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl containerd

#To install the latest, omit the version parameters, just make sure you're installing the same versions as on your Control Plane Node.
#sudo apt-get install kubelet kubeadm kubectl
#sudo apt-mark hold kubelet kubeadm kubectl

# Check the status of our kubelet and our container runtime.
# The kubelet will enter a crashloop until it's joined, but the containerd is up and running.
sudo systemctl status kubelet.service
sudo systemctl status containerd.service

# Ensure both are set to start when the system starts up.
sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service

# Log out of c1-node1 and back on to c1-cp1
exit
vagrant ssh c1-cp1

# On c1-cp1 - if you didn't keep the output, on the Control Plan Node, you can get the token.
kubeadm token list

# If you need to generate a new token, perhaps the old one timed out/expired.
kubeadm token create

# On the Control Plane Node, you can find the CA cert hash.
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

# You can also use print-join-command to generate token and print the join command in the proper format
# COPY THIS INTO YOUR CLIPBOARD
kubeadm token create --print-join-command

#Back on the worker node c1-node1, using the Control Plane Node (API Server) IP address or name, the token and the cert hash, let's join this Node to our cluster.
exit
vagrant ssh c1-node1

# PASTE JOIN COMMAND HERE be sure to add sudo
sudo kubeadm join 172.16.94.10:6443 \
  --token fmd8x8.3sxwaktkkyo3f3wo \
  --discovery-token-ca-cert-hash sha256:308187d7ff45bd17fe979a6afe511775a864d9cab916d055bd831adbe5ed6600 

# Log out of c1-node1 and back on to c1-cp1
exit
vagrant ssh c1-cp1

# Back on Control Plane Node, this will say NotReady until the networking pod is created on the new node.
# Has to schedule the pod, then pull the container.
kubectl get nodes

# On the Control Plane Node, watch for the calico pod and the kube-proxy to change to Running on the newly added nodes.
kubectl get pods --all-namespaces --watch

# Still on the Control Plane Node, look for this added node's status as ready.
kubectl get nodes

# GO BACK TO THE TOP AND DO THE SAME FOR c1-node2 and c1-node3
# Just SSH into c1-node2 and c1-node3 and run the commands again.
# You can skip the token re-creation if you have one that's still valid.

