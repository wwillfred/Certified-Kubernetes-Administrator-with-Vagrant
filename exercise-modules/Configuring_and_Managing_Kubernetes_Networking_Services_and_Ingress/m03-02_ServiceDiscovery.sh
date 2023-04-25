m03-02 Service Discovery

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/03_Configuring_and_Managing_Application_Access_with_Services

# Cluster DNS

# Let's create a deployment in the default namespace
kubectl create deployment hello-world-clusterip --image=psk8s.azurecr.io/hello-app:1.0

# Let's expose that deployment
kubectl expose deployment hello-world-clusterip \
    --port=80 --target-port=8080 --type ClusterIP

# We can use nslookup or dig to investigate the DNS record, its CNAME @10.96.0.10 is the
#   cluster IP of our DNS Server
kubectl get service kube-dns --namespace kube-system

# Each Service gets a DNS record. We can use this in our applications to find Services by name.
# The A record is in the form <servicename>.<namespace>.svc.<clusterdomain>
nslookup hello-world-clusterip.default.svc.cluster.local 10.96.0.10
kubectl get service hello-world-clusterip

# Create a namespace, deployment with one Replica and a Service
kubectl create namespace ns1


# Let's create a deployment with the same name as the first one, but in our new namespace
kubectl create deployment hello-world-clusterip --namespace ns1 \
    --image=psk8s.azurecr.io/hello-app:1.0

kubectl expose deployment hello-world-clusterip --namespace ns1 \
    --port=80 --target-port=8080 --type ClusterIP

# Let's check the DNS record for the Service in the namespace, ns1. See how ns1 is in the 
#   DNS record?
#<servicname>.<namespace>.svc.<clusterdomain>
nslookup hello-world-clusterip.ns1.svc.cluster.local 10.96.0.10

# Our service in the default namespace is still there, these are completely unique services.
nslookup hello-world-clusterip.default.svc.cluster.local 10.96.0.10


# Environment variables

# Get the environment variables for the Pod in our default namespace
# More details about the lifecycle of variables in "Configuring and Managing Kubernetes
#   Storage and Scheduling"
# Only the Kubernetes Service is available? Why? I created the Deployment THEN I created
#   the Service
PODNAME=$(kubectl get pods -o jsonpath='{ .items[].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- env | sort

# Environment variables are only created at Pod startup, so let's delete the Pod
kubectl delete pod $PODNAME

# And check the environment variables again
PODNAME=$(kubectl get pods -o jsonpath='{ .items[].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- env | sort

# ExternalName
kubectl apply -f service-externalname.yaml

# The record is in the form <servicename>.<namespace>.<clusterdomain>. You may get an
#   error that says ** server can't find hello-world.api.example.com: NXDOMAIN this is OK.
nslookup hello-world-api.default.svc.cluster.local 10.96.0.10

# Let's clean up our resources in this demo
kubectl delete service hello-world-api
kubectl delete service hello-world-clusterip
kubectl delete service hello-world-clusterip --namespace ns1
kubectl delete deployment hello-world-clusterip
kubectl delete deployment hello-world-clusterip --namespace ns1
kubectl delete namespace ns1
