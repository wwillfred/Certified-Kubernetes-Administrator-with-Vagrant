m03-01 Services

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/03_Configuring_and_Managing_Application_Access_with_Services

# 1 - Exposing and accessing applications with Services on our local cluster
# ClusterIP

# Imperative, create a Deployment with one Replica
kubectl create deployment hello-world-clusterip \
    --image=psk8s.azurecr.io/hello-app:1.0

# When creating a Service, you can define a type, if you don't define a type, the
#   default is ClusterIP
kubectl expose deployment hello-world-clusterip \
   --port=80 --target-port=8080 --type ClusterIP

# Get a list of Services, examine the Type, CLUSTER-IP and Port
kubectl get services

# Get the Service's ClusterIP and store that for reuse.
SERVICEIP=$(kubectl get service hello-world-clusterip -o jsonpath='{ .spec.clusterIP }')
echo $SERVICEIP

# Access the Service inside the cluster
curl http://$SERVICEIP

# Get a listing of the endpoints for a Service, we see the one Pod endpoint registered.
kubectl get endpoints hello-world-clusterip
kubectl get pods -o wide

# Access the Pod's application directly on the Target Port on the Pod, not the
#   Service's port, useful for troubleshooting.
# Right now there's only one Pod and its one endpoint
kubectl get endpoints hello-world-clusterip
PODIP=$(kubectl get endpoints hello-world-clusterip -o jsonpath='{ .subsets[].addresses[].ip }')
echo $PODIP
curl http://$PODIP:8080
