m03-01 Logging

vagrant ssh c1-cp1

cd /vagrant/declarative-config-files/Maintaining_Monitoring_and_Troubleshooting_Kubernetes/03_Logging_and_Monitoring_in_Kubernetes_Clusters

# 1 - Pods
# Check the logs for a single-container Pod.
kubectl create deployment nginx --image=nginx
PODNAME=$(kubectl get pods -l app=nginx -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME
kubectl logs $PODNAME

# Clean up that deployment
kubectl delete deployment nginx

# Let's create a multi-container Pod that writes some information to stdout
kubectl apply -f multicontainer.yaml

# Pods a specific Container in a Pod and a collection of Pods
PODNAME=$(kubectl get pods -l app=loggingdemo -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME

# Let's get the logs from the multicontainer Pod...this will throw an error and ask us
#   to define which container
kubectl logs $PODNAME

# But we need to specify which container inside the Pods
kubectl logs $PODNAME -c container1
kubectl logs $PODNAME -c container2

# We can access all container logs which will dump each containers' logs in sequence
kubectl logs $PODNAME --all-containers

# If we need to follow a log, we can do that...helpful in debugging real-time issues
# This works for both single- and multi-container Pods
kubectl logs $PODNAME --all-containers --follow
ctrl+c

# For all Pods matching the selector, get all the Container logs and write it to stdout
#   and then file
kubectl get pods --selector app=loggingdemo
kubectl logs --selector app=loggingdemo --all-containers
kubectl logs --selector app=loggingdemo --all-containers > allpods.txt

# Also helpful is tailing the bottom of a log...
# Here we're getting the last five log entries across all Pods matching the
#   selector
# You can do this for a single Container or using a selector
kubectl logs --selector app=loggingdemo --all-containers --tail 5


# 2 - Nodes
# Get key information and status about the kubelet, ensure that it's
#   active/running and check out the log.
# Also key information about its configuration is availabe.
systemctl status kubelet.service

# If we want to examine its log further, we use journalctl to access its log
#   from journald -u for which systemd unit. If using a pager, use f and b to
#   forward and back.
journalctl -u kubelet.service

# journalctl has search capabilities, but grep is likely easier
journalctl -u kubelet.service | grep -i ERROR

# Time bounding your searches can be helpful in finding issues and --no-pager
#   for line wrapping
journalctl -u kubelet.service --since today --no-pager


# 3 - Control plane
# Get a listing of the Control plane Pods using a selector
kubectl get pods --namespace kube-system --selector tier=control-plane

# We can retrieve the logs for the Control plane Pods by using kubectl logs
# This info is coming from the API server over kubectl, it instructs the
#   kubelet to read the log from the Node and send it back to you over stdout
kubectl logs --namespace kube-system kube-apiserver-c1-cp1

# But, what if your Control Plane is down? Go to crictl or to the file system.
# kubectl logs will send the request to the local Node's kubelet to read the logs from disk
# Since we're on the Control Plane Node already we can use crictl for that.
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps

# Grab the log for the api server pod, paste in the CONTINER ID using crictl
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps | grep kube-apiserver
CONTAINER_ID=$(sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps | grep kube-apiserver | awk '{ print $1 }')
echo $CONTAINER_ID
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock logs $CONTAINER_ID

# But, what if containerd isn't available?
# They're also available on the filesystem, here you'll find the current and the previous
#   logs' files for the containers.
# This is the same across all nodes and Pods in the cluster. This also applies to user pods/containers.
# These are json-formatted which is the docker/containerd logging driver default
sudo ls /var/log/containers
sudo tail /var/log/containers/kube-apiserver-c1-cp1*


# 4 - Events
# Show events for all objects in the cluster in the default namespace
# Look for the deployment creation and scaling operations from above...
# If you don't have any events since they are only around for an hour, create a Deployment
#   to generate some
kubectl get events

# It can be easier if the data are actually sorted...
# Sort by isn't for just events, it can be used in most outpu
kubectl get events --sort-by='.metadata.creationTimestamp'

# Create a flawed deployment
kubectl create deployment nginx --image ngins

# We can filter the list of events using field selector
kubectl get events --field-selector type=Warning
kubectl get events --field-selector type=Warning,reason=Failed

# We can also monitor the events as they happen with watch
kubectl get events --watch &
kubectl scale deployment loggingdemo --replicas=5

# Break out of the watch
fg
ctrl+c

# We can look in another namespace too if needed
kubectl get events --namespace kube-system

# These events are also available in the object as part of kubectl describe, in the events
#   section
kubectl describe deployment nginx
kubectl describe replicaset nginx-f9c6b9b99 #Update to your Replicaset name
kubectl describe pods nginx

# Clean up our resources
kubectl delete -f multicontainer.yaml
kubectl delete deployment nginx

# But the event data are still available from the cluster's events, even though the objects
#   are gone
kubectl get events --sort-by='.metadata.creationTimestamp'
