m03-03 Monitoring

vagrant ssh c1-cp1

cd /vagrant/declarative-config-files/Maintaining_Monitoring_and_Troubleshooting_Kubernetes/03_Logging_and_Monitoring_in_Kubernetes_Clusters


# Get the Metrics Server deployment manifest from github, the release version may change
# Check here for newer version ---> https://github.com/kubernetes-sigs/metrics-server
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.3/components.yaml

vi components.yaml
# Add these two lines to metrics server's container args, around line 132
# - --kubelet-insecure-tls
# - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname


# Deploy the manifest for the Metrics Server
kubectl apply -f components.yaml

# Is the Metrics Server running?
kubectl get pods --namespace kube-system

# Let's test it to see if it's collecting data, we can get core information about memory
#   and CPU.
# This can take a second...
kubectl top nodes

# If you have any issues check out the logs for the Metrics Server...
kubectl logs --namespace kube-system -l k8s-app=metrics-server

# Let's check the perf data for Pods, but there's no Pods in the default namespace
kubectl top pods

# We can look at our system pods, CPU and memory
kubectl top pods --all-namespaces

# Let's deploy a Pod that will burn a lot of CPU, but single threaded we have two vCPUs
#   in our Nodes.
kubectl apply -f cpuburner.yaml

# And create a deployment and scale it.
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3

# Are our Pods up and running?
kubectl get pods -o wide

# How about that CPU now, one of the Nodes should have about 50% CPU, one should be
#   1000m+    Recall 1000m = 1vCPU.
# We can see the resource allocations across the Nodes in terms of CPU and memory.
kubectl top nodes

# Let's get the perf across all Pods...it can take a second after the deployments are
#   created to get data
kubectl top pods

# We can use labels and selectors to query subsets of Pods
kubectl top pods -l app=cpuburner

# And we have primitive sorting, top CPU and top memory consumers across all Pods
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory

# Now, that cpuburner, let's look a little more closely at it. We can ask for perf for
#   the containers inside a Pod
kubectl top pods --containers


# Clean up our resources
kubectl delete deployment cpuburner
kubectl delete deployment nginx

# Delete the Metrics Server and its configuration elements
kubectl delete -f components.yaml
