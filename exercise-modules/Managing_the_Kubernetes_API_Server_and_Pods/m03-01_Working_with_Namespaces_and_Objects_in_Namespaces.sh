# m03-01

# Get a list of all the namespaces in our cluster
kubectl get namespaces

# get a list of all the API resources and if they can be in a namespace
kubectl api-resources --namespaced=true | head
kubectl api-resources --namespaced=false | head

# Namespaces have state, Active and Terminating (when it's deleting)
kubectl describe namespaces

# Describe the details of an individual namespace
kubectl describe namespaces kube-system

# Get all the pods in our cluster across all namespaces. Right now, only system pods, no user workload.
# You can shorten --all-namespaces to -A
kubectl get pods --all-namespaces

# Get all the resources across all of our namespaces
kubectl get all --all-namespaces

# Get a list of the pods in the kube-system namespace
kubectl get pods --namespace kube-system

# Imperatively create a namespace
kubectl create namespace playground1

# Imperatively create a namepsace...but there's some character restrictions. Lower case and only dashes.
kubectl create namespace Playground1

# Declaratively create a namespace
more /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/03_Managing_Objects_with_Labels_Annotations_and_Namespaces/namespace.yaml
kubectl apply -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/03_Managing_Objects_with_Labels_Annotations_and_Namespaces/namespace.yaml

# Get a list of all the current namespaces
kubectl get namespaces

# Start a deployment into our playground1 namespace
more /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/03_Managing_Objects_with_Labels_Annotations_and_Namespaces/deployment.yaml
kubectl apply -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/03_Managing_Objects_with_Labels_Annotations_and_Namespaces/deployment.yaml

# Creating a resource imperatively...the generator parameter is deprecated and removed from the demo.
kubectl run hello-world-pod \
    --image=gcr.io/google-samples/hello-app:1.0 \
    --namespace playground1

# Where are the pods?
kubectl get pods

# List all the pods on our namespace
kubectl get pods --namespace playground1
kubectl get pods -n playground1

# Get a list of all of the resources in our namespace...Deployment, ReplicaSet and Pods
kubectl get all --namespace=playground1
