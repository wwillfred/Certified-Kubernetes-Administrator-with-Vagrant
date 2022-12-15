# m02-01

vagrant ssh c1-cp1

# API Discovery
# Get information about our current cluster context, ensure we're logged into the correct cluster.
kubectl config get-contexts

# Change our context if needed by specifying the Name
kubectl config use-context kubernetes-admin@kubernetes

# Get information about the API Server for our current context, which should be kubernetes-admin@kubernetes
kubectl cluster-info

# Get a list of API Resources available in the cluster
kubectl api-resources | more

# Using kubectl explain to see the structure of a resource...specifically its fields
# In addition to using the API reference on the web this is a great way to discover what it takes to write yaml manifests
kubectl explain pods | more

# Let's look more closely at what we need in pod.spec and pod.spec.containers (image and name are required)
kubectl explain pod.spec | more
kubectl explain pod.spec.containers | more

# Let's check out some YAML and creating a pod with YAML
kubectl apply -f /vagrant/pod.yaml

# Get a list of our currently running pods
kubectl get pods

# Remove our pod...this command blocks and can take a second to complete
kubectl delete pod hello-world
