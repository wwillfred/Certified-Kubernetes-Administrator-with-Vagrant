# m04-01: Pods

cd /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/04_Running_and_Managing_Pods

# Start up kubectl get events --watch and background it.
kubectl get events --watch &

# Create a pod...we can see the scheduling, container pulling and container starting.
kubectl apply -f pod.yaml

# Start a Deployment with 1 replica. We see th deployment created, scaling the replica set and the replica set starting the first pod
kubectl apply -f deployment.yaml
