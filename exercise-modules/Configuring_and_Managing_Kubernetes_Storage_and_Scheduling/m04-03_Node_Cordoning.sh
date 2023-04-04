# m04-03 Node Cordoning

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/04_Managing_and_Controlling_the_Kubernetes_Scheduler

# Demo 1 - Node Cordoning
# Let's create a deployment with three replicas
kubectl apply -f deployment.yaml

# Pods spread out evenly across the nodes
kubectl get pods -o wide

# Let's cordon c1-node3
kubectl cordon c1-node3

# That won't evic any pods...
kubectl get pods -o wide

# But if I scale the deployment
kubectl scale deployment hello-world --replicas=6

# c1-node3 won't get any new Pods... one of the other Nodes will get an extra Pod here.
kubectl get pods -o wide

# Let's drain (remove) the Pods from c1-node3...
kubectl drain c1-node3

# Let's try that again since daemonsets aren't scheduled we need to work around them
kubectl drain c1-node3 --ignore-daemonsets

# now all the workload is on c1-node1 and 2
kubectl get pods -o wide

# We can uncordon c1-node3, but nothing will get scheduled there until there's an event
#   like a scaling operation or an eviction
# Something that will cause Pods to get created
kubectl uncordon c1-node3

# So let's scale that Deployment and see where they get schedueld...
kubectl scale deployment hello-world --replicas=9

# All three get scheduled to the cordoned node
kubectl get pods -o wide

# Clean up this demo...
kubectl delete deployment hello-world
