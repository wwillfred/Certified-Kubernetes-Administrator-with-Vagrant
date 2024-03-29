# m03-03

## Create control plane node - containerd

###IMPORTANT###
# If you are using containerd, make sure Docker isn't installed.
# kubeadm init will try to auto-detect the container runtaime and at the moment
# if both are installed it will pick docker first.
# sudo apt-get remove docker

### 0 - Create a cluster
# Create our kubernetes cluster, specify a pod network range matching that in calico.yaml!
# Only on the Control Plane Node, download the yaml files for the pod network.
wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

# Look inside calico.yaml and find the setting for Pod Network IP address range CALICO_IPV4POOL_CIDR,
# adjust if needed for your infrastructure to ensure that the Pod network IP
# range doesn't overlap with other networks in our infrastructure.
vi calico.yaml

# You can now just use kubeadm init to bootstrap the cluster
# the IP addresses are important because of Vagrant's networking implementation!!!
sudo kubeadm init --kubernetes-version v1.27.1 --apiserver-advertise-address="172.16.94.10" --apiserver-cert-extra-sans="172.16.94.10" --pod-network-cidr=192.168.0.0/16

# sudo kubeadm init --apiserver-advertise-address="172.16.94.10" --apiserver-cert-extra-sans="172.16.94.10" --pod-network-cidr=192.168.0.0/16 # remove the kubernetes-version parameter if you want to use the latest.

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

# Check out the directory where the kubeconfig files live for each of the control plane pods.
ls /etc/kubernetes

# Configure kubectl to use the internal IP address that we configured for the Vagrant private network.
# We have to do this because by default, kubelet uses the IP address of the first Ethernet adapter, which can only be used by Vagrant to ssh into the node.

IP_ADDR=$(ip -o -4 addr list eth1 | awk '{print $4}' | cut -d/ -f1)
echo "KUBELET_EXTRA_ARGS='--node-ip $IP_ADDR'" | sudo tee /etc/default/kubelet

# Restart kubelet to read the IP address from the config file we just created.
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Verify that the Control Plane node's internal IP address was correctly configured:
kubectl get nodes -o wide

# disconnect from c1-cp1
exit
