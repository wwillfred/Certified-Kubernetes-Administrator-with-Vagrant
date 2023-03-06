# m03-01 Environment variables

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/03_Configuration_as_Data_Environment_Variables_Secrets_and_ConfigMaps

# Demo 1 - Passing Configuration into Containers using Environment Variables
# Create two deployments, one for a database system and the other for our application.
# We're putting a little wait in there so the Pods are created one after the other.
kubectl apply -f deployment-alpha.yaml
sleep 10
kubectl apply -f deployment-beta.yaml

# Let's look at the services
kubectl get service

# Now let's get the name of one of our pods
PODNAME=$(kubectl get pods | grep hello-world-alpha | awk '{print $1}' | head -n 1)
echo $PODNAME

# Inside the Pod, let's read the environment variables from our container.
# Notice the alpha information is there but not the beta information. Since beta wasn't
# defined when the Pod started.
kubectl exec -it $PODNAME -- /bin/sh
printenv | sort
exit

# If you delete the Pod and it gets recreated, you will get the variables for the alpha
#   and beta service information.
kubectl delete pod $PODNAME

# Get the new Pod name and check the environment variables...the variables are defined at
#   Pod/Container startup.
PODNAME=$(kubectl get pods | grep hello-world-alpha | awk '{print $1}' | head -n 1)
kubectl exec -it $PODNAME -- /bin/sh -c "printenv | sort"
