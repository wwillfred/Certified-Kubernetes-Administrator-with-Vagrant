# m03-04 ConfigMaps

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/03_Configuration_as_Data_Environment_Variables_Secrets_and_ConfigMaps

# Demo 1 - Creating ConfigMaps
# Create a PROD ConfigMap
kubectl create configmap appconfigprod \
    --from-literal=DATABASE_SERVERNAME=sql.example.local \
    --from-literal=BACKEND_SERVERNAME=be.example.local

# Create a QA ConfigMap
# We can source our ConfigMap from files or from directories
# If no key, then the base name of the file
# Otherwise we can specify a key name to allow for more complex app configs and access to
#   specific configuration elements
more appconfigqa
kubectl create configmap appconfigqa \
    --from-file=appconfigqa

# Each creation method yeilded a different structure in the ConfigMap
kubectl get configmap appconfigprod -o yaml
kubectl get configmap appconfigqa -o yaml


# Demo 2 - Using ConfigMaps in Pod Configurations
# First as environment variables
kubectl apply -f deployment-configmaps-env-prod.yaml

# Let's see our configured environment variables
PODNAME=$(kubectl get pods | grep hello-world-configmaps-env-prod | awk '{print $1}' | head -n 1)
echo $PODNAME

kubectl exec -it $PODNAME -- /bin/sh
printenv | sort
exit
