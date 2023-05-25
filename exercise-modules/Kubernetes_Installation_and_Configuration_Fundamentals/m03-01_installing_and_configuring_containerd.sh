# m03-01

## Installing and Configuring containerd

### 0 - Install packages

# ssh into c1-cp1
vagrant ssh c1-cp1

Check that swap is disabled:
vagrant ssh c1-cp1
sudo swapon --show # if this command has no output, then swap is disabled

# containerd prerequisites, first load two modules and configure them to load on boot
# https://kubernetes.io.docs/setup/production-environment/container-runtimes/
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install containerd... we need to install from the Docker repo to get containerd 1.6, the
#   Ubuntu repo stops at 1.5.9
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io

# Create a containerd configuration file
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Set the cgroup driver for containerd to systemd which is required for the kubelet
# For more information on this config file see:
# https://github.com/containerd/cri/blob/master/docs/config.md and also
# https://github.com/containerd/containerd/blob/master/docs/ops.md

# Change SystemdCgroup = false to SystemdCgroup = true
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Verify the change was made
sudo vi /etc/containerd/config.toml

# Restart containerd with the new configuration
sudo systemctl restart containerd
