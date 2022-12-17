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
kubectl apply -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/02-Using_the_Kubernetes_API/pod.yaml

# Get a list of our currently running pods
kubectl get pods

# Remove our pod...this command blocks and can take a second to complete
kubectl delete pod hello-world

# Working with kubectl dry-run
# Use kubectl dry-run for server-side validation of a manifest...the object will be sent to the API Server.
# dry-run=server will tell you the object was created...but it wasn't...
# it just goes through the whole process but didn't get stored in etcd.
kubectl apply -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/02-Using_the_Kubernetes_API/deployment.yaml --dry-run=server

# No deployment is created
kubectl get deployments

# Use kubectl dry-run for client-side validation of a manifest...
kubectl apply -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/02-Using_the_Kubernetes_API/deployment.yaml --dry-run=client

# Let's do that one more time but with an error... replica should be replicas
kubectl apply -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/02-Using_the_Kubernetes_API/deployment-error.yaml --dry-run=client

# Use kubectl dry-run client to generate some yaml...for an object
kubectl create deployment nginx --image=nginx --dry-run=client

# Combine dry-run client with -o yaml and you'll get the YAML for the object...in this case a deployment
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml | more

# Can be any object...let's try a pod...
kubectl run pod nginx-pod --image=nginx --dry-run=client -o yaml | more

# We can combine that with IO redirection and store the YAML into a file
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment-generated.yaml
more deployment-generated.yaml

# And then we can deploy from that manifest...or use it as a building block for more complex manifests
kubectl apply -f deployment-generated.yaml

# Clean up from that demo...you can use delete with -f to delete all the resources in the manifests
kubectl delete -f deployment-generated.yaml


# Working with kubectl diff
# Create a deployment with 4 replicas
kubectl apply -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/02-Using_the_Kubernetes_API/deployment.yaml

# Diff that with a deployment with 5 replicas and a new container image...you will see other metadata about the object output too.
kubectl diff -f /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/02-Using_the_Kubernetes_API/deployment-new.yaml | more

# Clean up from this demo...you can use delete with -f to delete all the resources in the manifests
kubectl delete -f deployment.yaml
