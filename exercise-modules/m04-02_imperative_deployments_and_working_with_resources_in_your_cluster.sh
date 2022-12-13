# m04-02.sh

## Deploying resources imperatively in your cluster

# kubectl create deployment, creates a Deployment with one replica in it.
# This is pulling a simple hello-world app container image from Google's container repository.
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0

# But let's deploy a single "bare" pod that's not managed by a controller...
kubectl run hello-world-pod --image=gcr.io/google-samples/hello-app:1.0

# Let's see if the Deployment creates a single replica and also see if that bare pod is created.
# You should have two pods here...
# - the one managed by our controller has the pod template hash in its name and a unique identifier
# - the bare pod
kubectl get pods
kubectl get pods -o wide

# Rembember, k8s is a container orchestrator and it's starting up containers on Nodes.

# Open a second terminal and ssh into the node that hello-world pod is running on.
vagrant ssh c1-node[XX]

# When containerd is your container runtime, use crictl to get a listing of the containers running
# Check out this for more details https://kubernetes.io/docs/tasks/debug-application-cluster/crictl
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps

# Log out of the Node and back into the Control Plane node, c1-cp1
exit

# Back on c1-cp1, we can pull the logs from the container. Which is going to be anything written to stdout.
# Maybe something went wrong inside our app and our pod won't start. This is useful for troubleshooting.
kubectl logs hello-world-pod

# Starting a process inside a container inside a pod.
# We can use this to launch any process as long as the executable/binary is in the container.
# Launch a shell into the container. Callout that this is on the *pod* network.
# NOTE: I've been unable to successfully attach a shell to this container.
kubectl exec -it hello-world-pod -- /bin/sh
hostname
ip addr
exit
