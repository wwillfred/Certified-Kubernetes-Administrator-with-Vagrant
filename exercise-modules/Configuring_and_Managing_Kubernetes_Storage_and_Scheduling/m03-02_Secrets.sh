# m03-02 Secrets

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/03_Configuration_as_Data_Environment_Variables_Secrets_and_ConfigMaps

# Demo 1 - Creating and accessing Secrets
# Generic - Create a secret from a local file, directory, or literal value
# The keys and values are case sensitive
kubectl create secret generic app1 \
    --from-literal=USERNAME=app1login \
    --from-literal=PASSWORD='S0methingS@Str0ng!'

# Opaque means it's an arbitrary user-defined key-value pair. Data 2 means two key/value
# pairs in the secret.
# Other types include service accounts and container registry authentication info
kubectl get secrets

# app1 said it had 2 Data elements, let's look
kubectl describe secret app1

# If we need to access those at the command line...
# These are wrapped in bash expansion to add a newline to output for readability
echo $(kubectl get secret app1 --template={{.data.USERNAME}} )
echo $(kubectl get secret app1 --template={{.data.USERNAME}} | base64 --decode )

echo $(kubectl get secret app1 --template={{.data.PASSWORD}} )
echo $(kubectl get secret app1 --template={{.data.PASSWORD}} | base64 --decode )


# Demo 2 - Accessing Secrets inside a Pod
# As environment variables
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/03_Configuration_as_Data_Environment_Variables_Secrets_and_ConfigMaps

kubectl apply -f deployment-secrets-env.yaml

PODNAME=$(kubectl get pods | grep hello-world-secrets-env | awk '{print $1}' | head -n 1)
echo $PODNAME

# Now let's get our environment variables from our container
kubectl exec -it $PODNAME -- /bin/sh
printenv | grep ^app1
exit

# Accessing Secrets as files
kubectl apply -f deployment-secrets-files.yaml

# Grab our Pod name into a variable
PODNAME=$(kubectl get pods | grep hello-world-secrets-files | awk '{print $1}' | head -n 1)
echo $PODNAME

# Looking more closely at the Pod we see volumes, appconfig and in Mounts...
kubectl describe pod $PODNAME

# Let's access a shell on the Pod
kubectl exec -it $PODNAME -- /bin/sh

# Now we see the path we defined in the Volumes part of the Pod Spec
# A directory for each KEY and its contents are the value
ls /etc/appconfig
cat /etc/appconfig/USERNAME
cat /etc/appconfig/PASSWORD
exit

#If you need to put only a subset of the keys in a secret check out this line here and look at items
#https://kubernetes.io/docs/concepts/storage/volumes#secret

# Let's clean up after our demos...
kubectl delete secret app1
kubectl delete deployment hello-world-secrets-env
kubectl delete deployment hello-world-secrets-files
