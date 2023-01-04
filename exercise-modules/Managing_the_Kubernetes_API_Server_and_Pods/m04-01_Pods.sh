# m04-01: Pods

cd /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/04_Running_and_Managing_Pods

# Start up kubectl get events --watch and background it.
kubectl get events --watch &

# Create a pod...we can see the scheduling, container pulling and container starting.
kubectl apply -f pod.yaml

# Start a Deployment with 1 replica. We see th deployment created, scaling the replica set and the replica set starting the first pod
kubectl apply -f deployment.yaml

# Scale a Deployment to 2 replicas. We see the scaling the replica set and the replica set starting the second pod.
kubectl scale deployment hello-world --replicas=2

# We start off with the replica set scaling to 1, then Pod deletion, then the Pod killing the container
kubectl scale deployment hello-world --replicas=1

kubectl get pods

# Let's use exec a command inside our container, we can see the GET and POST API requests through the API server to reach the pod.
kubectl -v 6 exec -it hello-world-7c649d8c6f-w4zfp -- /bin/sh # need to find out why this doesn't work
ps
exit

# Let's look at the running container-pod from the process level on a Node.
kubectl get pods -o wide
ssh aen@c1-node1 # need to find out why this doesn't work
ps -aux | grep hello-app
exit

# Now, let's access our Pod's application directly, without a service and also off the Pod network.
kubectl port-forward hello-world-7c649d8c6f-w4zfp 80:8080

# Let's do it again, but this time with a non-priviledged port
kubectl port-forward hello-world-7c649d8c6f-w4zfp 8080:8080 &

# We can now point curl to localhost, and kubectl port-forward will send the traffic through the API server to the Pod
curl http://localhost:8080

# Kill our port-forward session.
fg
ctrl+c

kubectl delete deployment hello-world
kubectl delete pod hello-world-pod

fg
ctrl+c
