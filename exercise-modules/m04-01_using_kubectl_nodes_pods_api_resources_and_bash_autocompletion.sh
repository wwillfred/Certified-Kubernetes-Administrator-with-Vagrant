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
