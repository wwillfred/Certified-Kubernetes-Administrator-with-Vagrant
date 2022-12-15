# m04

## Using kubectl: Nodes, pods, API resources and bash auto-completion

vagrant ssh c1-cp1

# Listing and inspecting your cluster...helpful for knowing which cluster is your current context
kubectl cluster-info

# One of the most common operations you will use is get...
# Review status, roles and versions
kubectl get nodes

# You can add an output modifier to get more information about a resource
# Additional info about each node in the cluster
kubectl get nodes -o wide

# Let's get a list of pods...but there isn't any running.
kubectl get pods

# True, but let's get a list of system pods. A namespace is a way to group resources together.
kubectl get pods --namespace kube-system

# Let's get additional information about each pod.
kubectl get pods --namespace kube-system -o wide

# Now let's get a list of everything that's running in all namespaces
# In addition to pods, we see services, daemonsets, deployments and replicasets
kubectl get all --all-namespaces | more

# Asking Kubernetes for the resources it knows about
# Let's look at the headers in each column. 
# E.g. StorageClass isn't in a namespace so it's available to all namespaces.
# Kind is the object type
kubectl api-resources | more

# no is alias for nodes
kubectl get no

# We can filter using grep
kubectl api-resources | grep pod

# Explain an individual resource in detail
kubectl explain pod | more
kubectl explain pod.spec | more
kubectl explain pod.spec.container | more
kubectl explain pod --recursive | more

# We can take a closer look at our nodes using Describe
# Check out Name, Taints, Conditions, Addresses, System Info, etc.
kubectl describe nodes c1-cp1 | more
kubectl describe nodes c1-node1 | more

# Use -h or --help to find help
kubectl -h | more
kubectl get -h | more
kubectl create -h | more

# Now let's enable bash auto-complete of our kubectl commands
sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc
kubectl g[tab][tab] po[tab][tab] --all[tab][tab]
