# m04-03: Pod Lifecycle

vagrant ssh c1-cp1
cd /vagrant/Managing_the_Kubernetes_API_Server_and_Pods/04_Running_and_Managing_Pods

# Start up kubectl get events --watch and background it.
kubectl get events --watch &
clear

# Create a pod...we can see the scheduling, container pulling and container starting.
kubectl apply -f pod.yaml

# We've used exec to launch a shell before, but we can use it to launch ANY program inside a container.
# Let's use killall to kill the hello-app process inside our container
kubectl exec -it hello-world-pod -- /bin/sh
