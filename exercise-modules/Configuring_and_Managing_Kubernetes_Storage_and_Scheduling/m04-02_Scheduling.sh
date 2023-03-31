# m04-02 Scheduling

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/04_Managing_and_Controlling_the_Kubernetes_Scheduler

# Demo - Using Labels to Schedule Pods to Nodes
# The code is below experiment with on your own.
#  Course: Managing the Kubernetes API Server and Pods
#  Module: Managing Objects with Labels, Annotations, and Namespaces
#  Clip:   Demo: Services, Labels, Selectors, and Scheduling Pods to Nodes


# Demo 1a - Using Affinity and Anti-Affinity to schedule Pods to Nodes
# Let's start off with a deployment of web and cache pods
# Affinity: we want to have always a cache pod co-located on a Node where we
#   have a Web Pod
kubectl apply -f deployment-affinity.yaml

# Let's check out the labels on the nodes, look for kubernetes.io/hostname
#   which we're using for our topology key
kubectl describe nodes c1-node1 | head
kubectl get nodes --show-labels


# We can see that web and cache are both on the name node
kubectl get pods -o wide


# If we scale the web deployment
# We'll still get spread across nodes in the ReplicaSet, so we don't need to enforce that with affinity
kubectl scale deployment hello-world-web --replicas=2
kubectl get pods -o wide

# Then when we scale the cache deployment, it will get scheduled to the same node as
#   the other web server
kubectl scale deployment hello-world-cache --replicas=2

# Clean up the resources from these deployments
kubectl delete -f deployment-affinity.yaml


# Demo 1b - Using anti-affinity
# Now, let's test out anti-affinity, deploy web and cache again
# But this time we're going to make sure that no more than 1 web pod is on each
#   node with anti-affinity
kubectl apply -f deployment-antiaffinity.yaml
kubectl get pods -o wide

# Now let's scale the replicas in the web and cache deployments
kubectl scale deployment hello-world-web --replicas=4

# One Pod will go Pending because we can have only 1 Web Pod per node when using
#   requiredDuringSchedulingIgnoredDuringExecution in our antiaffinity rule
kubectl get pods -o wide --selector app=hello-world-web

# To 'fix' this we can change the scheduling rule to preferredDuringSchedulingIgnoredDuringExecution
# Also going to set the number of replicas to 4
kubectl apply -f deployment-antiaffinity-corrected.yaml
kubectl scale deployment hello-world-web --replicas=4

# Now we'll have 4 Pods up and running, but doesn't the scheduler already ensure
#   replicaset spread? Yes!
kubectl get pods -o wide --selector app=hello-world-web

# Let's clean up the resources from this demo
kubectl delete -f deployment-antiaffinity-corrected.yaml
