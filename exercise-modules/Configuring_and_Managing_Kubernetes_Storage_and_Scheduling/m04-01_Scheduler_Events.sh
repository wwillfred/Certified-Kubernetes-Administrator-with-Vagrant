# m04-01 Environment Variables

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/04_Managing_and_Controlling_the_Kubernetes_Scheduler

# Demo 1 - Finding scheduling information
# Let's create a deployment with three replicas
kubectl apply -f deployment.yaml

# Pods spread out evenly across the Nodes due to our scoring functions for
#   selector spread during Scoring.
kubectl get pods -o wide

# We can look at the Pods events to see the scheduler making its choice
kubectl describe pods

# If we scale our deployment to 6...
kubectl scale deployment hello-world --replicas=6

# We can see that the scheduler works to keep load even across the nodes.
kubectl get pods -o wide

# We can see the nodeName populated for this node
kubectl get pods hello-world-[tab][tab] -o yaml

# Clean up this demo...and delete its resources
kubectl delete deployment hello-world


# Demo 2 - Scheduling Pods with resource requests. Start a watch, the pods will go
#   from Pending->ContainerCreating->Running
# Each pod has a 1 core CPU request.
kubectl get pods --watch &
kubectl apply -f requests.yaml

# We created three pods, one on each node
kubectl get pods -o wide

# Let's scale our deployment to 6 replicas. These pods will stay pending. Some
#   pod names may be repeated.
kubectl scale deployment hello-world-requests --replicas=6

# We see that three Pods are pending...why?
kubectl get pods -o wide
kubectl get pods -o wide | grep Pending

# Let's look at why the Pod is Pending...check out the pod's events...
kubectl describe pods

# Now let's look at the Node's Allocations...we've allocated 62% of our CPU...
# 1 User Pod using 1 whole CPU, one system Pod using 250 millicores of a CPU and
#   looking at allocatable resources, we have only 2 whole Cores available for use.
# The next Pod coming along wants 1 whole core, and that's not availabe.
# The scheduler can't find a place in this cluster to place our workload... is this
#   good or bad?
kubectl describe node c1-node1

# Clean up after this demo
kubectl delete deployment hello-world-requests

# stop the watch
fg
ctrl+c
