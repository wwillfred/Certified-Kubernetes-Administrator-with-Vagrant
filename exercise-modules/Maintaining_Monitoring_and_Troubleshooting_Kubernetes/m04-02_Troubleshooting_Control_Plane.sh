m04-02 Troubleshooting Control Plane

vagrant ssh c1-cp1

cd /vagrant/declarative-config-files/Maintaining_Monitoring_and_Troubleshooting_Kubernetes/04_Troubleshooting_Kubernetes_Clusters

# 1 - Control Plane Pods stopped
# Remember the Control Plane Node still has a kubelet and runs Pods...if the kubelet's not
#   running then troubleshoot that first.
# This section focuses on the Control Plane when it's running the Control Plane's Pods
# Run this script on your Control Plane Node to break the Control Plane
# m04-02_Troubleshooting_Control_Plane_Break_Stuff-1.sh 

# Let's check the status of our Control Plan Pods...refused?
# It can take a bit to break the Control Plane...wait until its connection to server was
#   refused.
kubectl get pods --namespace kube-system

# Let's ask our Container runtime what's up... well there are Pods running on this Node,
#   but no Control Plane Pods.
# That's your clue... no Control Plane Pods running... what starts up the Control Plane
#   Pods... static Pod manifests
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps

# Let's check config.yaml for the location of the static Pod manifests
# Look for staticPodPath
# Do the yaml files exist at that location?
sudo more /var/lib/kubelet/config.yaml

# The directory doesn't exist...oh no!
sudo ls -laR /etc/kubernetes/manifests

# Let's look up one directory...
sudo ls -la /etc/kubernetes/

# We could update config.yaml to point to this path or rename it to put the manifests
#   in the configured location
# The kubelet will find these manifests and launch the Pods again
sudo mv /etc/kubernetes/manifests.wrong /etc/kubernetes/manifests
sudo ls /etc/kubernetes/manifests

# Check the Container runtime to ensure the Pods are started... we can see they were
#   created and running just a few seconds ago
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps

# Let's ask Kubernetes what it thinks...
kubectl get pods -n kube-system


# 2 - Troubleshooting Control Plane failure, user Pods are all pending.

# Break the Control Plane
# m04-02_Troubleshooting_Control_Plane_Break_Stuff-2.sh

# Let's start a workload 
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=4

# Interesting, all of the Pods are pending...why?
kubectl get pods

# Nodes look good? Yes, they're all reporting ready.
kubectl get nodes

# Let's look at the Pods' events...<none> nothing, no scheduling, no image pulling,
#   no Container starting...let's zoom out
kubectl describe pods

# What's the next step after the Pods are created by the replication controller?
#   Scheduling...
kubectl get events --sort-by='.metadata.creationTimestamp'

# So we know there's no scheduling events, let's check the Control Plane status...the
#   scheduler isn't running
kubectl get pods --namespace=kube-system

# Let's check the events on that Pod... we can see if failed to pull the image for the
#   scheduler, says image not found.
# Looks like the manifest is trying to pull an image that doesn't exist
kubectl describe pods --namespace kube-system kube-scheduler-c1-cp1

# That's defined in the static pod manifest
sudo vi /etc/kubernetes/manifests/kube-scheduler.yaml

# Is the scheduler back online? Yes, it's running
kubectl get pods --namespace=kube-system

# And our Deployment is up and running... might take a minute or two for the Pods to
#   start up.
kubectl get deployment

# Clean up our resources...
kubectl delete deployments.apps nginx
