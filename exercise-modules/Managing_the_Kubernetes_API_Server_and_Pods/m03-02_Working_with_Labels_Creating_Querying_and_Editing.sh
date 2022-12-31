# m03-02

cd /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/03_Managing_Objects_with_Labels_Annotations_and_Namespaces/

# Create a collection of pods with labels assigned to each
more CreatePodsWithLabels.yaml
kubectl apply -f CreatePodsWithLabels.yaml

# Look at all the Pod labels in our cluster
kubectl get pods --show-labels

# Look at one Pod's labels in our cluster
kubectl describe pod nginx-pod-1 | head

# Query labels and selectors
kubectl get pods --selector tier=prod
kubectl get pods --selector tier=qa
kubectl get pods -l tier=prod
kubectl get pods -l tier=prod --show-labels

# Selector for multiple labels and adding on show-labels to see those labels in the output
kubectl get pods -l 'tier=prod,app=MyWebApp' --show-labels
kubectl get pods -l 'tier=prod,app!=MyWebApp' --show-labels
kubectl get pods -l 'tier in (prod,qa)'
kubectl get pods -l 'tier notin (prod,qa)'

# Output a particular label in column format
kubectl get pods -L tier
kubectl get pods -L tier,app

# Edit an existing label
kubectl label pod nginx-pod-1 tier=non-prod --overwrite
kubectl get pod nginx-pod-1 --show-labels

# Adding a new label
kubectl label pod nginx-pod-1 another=Label
kubectl get pod nginx-pod-1 --show-labels

# Removing an existing label
kubectl label pod nginx-pod-1 another-
kubectl get pod nginx-pod-1 --show-labels

# Performing an operation on a collection of pods based on a label query
kubectl label pod --all tier=non-prod --overwrite
kubectl get pod --show-labels

# Delete all pods matching our non-prod label
kubectl delete pod -l tier=non-prod

# And we're left with nothing.
kubectl get pods --show-labels

# Kubernetes Resource Management
# Start a Deployment with 3 replicas, open deployment-label.yaml
kubectl apply -f deployment-label.yaml

# Expose our Deployment as a Service, open service.yaml
kubectl apply -f service.yaml

# Look at the Labels and Selectors on each resource, the Deployment, ReplicaSet and Pod
# The deployment has a selector for app=hello-world
kubectl describe deployment hello-world

# The ReplicaSet has labels and selectors for app and the current pod-template-hash
# Look at the Pod Template and the labels on the Pods created
kubectl describe replicaset hello-world

# The Pods have labels for app=hello-world and for the pod-template-hash of the current ReplicaSet
kubectl get pods --show-labels

# Edit the label on one of the Pods in the ReplicaSet, change the pod-template-hash
kubectl label pod hello-world-7c649d8c6f-8z4ct pod-template-hash=DEBUG --overwrite

# The ReplicaSet will deploy a new Pod to satisfy the number of replicas. Our relabeled Pod still exists.
kubectl get pods --show-labels

# Let's look at how Services use labels and selectors, check out service.yaml
kubectl get service

# The selector for this service is app=hello-world, that pod is still being load-balanced to!
kubectl describe service hello-world

# Get a list of all IPs in the service, there's 5...why?
kubectl describe endpoints hello-world

#Get a list of pods and their IPs
kubectl get pod -o wide

# To remove a pod from load balancing, change the label used by the service's selector.
# The ReplicaSet will respond by placing another pod in the ReplicaSet
kubectl get pods --show-labels
kubectl label pod hello-world-7c649d8c6f-8z4ct app=DEBUG --overwrite

