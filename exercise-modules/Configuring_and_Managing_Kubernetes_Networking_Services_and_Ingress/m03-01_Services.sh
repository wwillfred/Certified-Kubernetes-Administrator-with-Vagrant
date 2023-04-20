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

# Scale the deployment, new endpoints are registered automatically
kubectl scale deployment hello-world-clusterip --replicas=6
kubectl get endpoints hello-world-clusterip

# Access the Service inside the cluster, this time our requests will be load
#   balanced...whooo!
curl http://$SERVICEIP

# The Service's Endpoints match the labels, let's look at the Service and its
#   selector and the Pod's labels
kubectl describe service hello-world-clusterip
kubectl get pods --show-labels

# Clean up these resources for the next demo
kubectl delete deployments hello-world-clusterip
kubectl delete service hello-world-clusterip


# 2 - Creating a NodePort Service
# Imperative, create a Deployment with one Replica
kubectl create deployment hello-world-nodeport --image=psk8s.azurecr.io/hello-app:1.0

# When creating a Service, you can define a type, if you don't define a type, the
#   default is ClusterIP
kubectl expose deployment hello-world-nodeport \
    --port=80 --target-port=8080 --type NodePort

# Let's check out the Services details, there's the Node Port after the : in the Ports
#   column. It's also got a ClusterIP and Port
# This NodePort Service is available on that NodePort on each node in the cluster
kubectl get service

CLUSTERIP=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.clusterIP }')
PORT=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.ports[].port }')
NODEPORT=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.ports[].nodePort }')

# Let's access the Services on the Node Port...we can do that on each Node in the
#   cluster and from outside the cluster...regardless of where the Pod actually is

# We have only one Pod online supporting our Service
kubectl get pods -o wide

# And we can access the Service by hitting the Node port on ANY node in the cluster on
#   the Node's real IP or Name
# This will forward to the cluster IP and get load balanced to a Pod. Even if there is
#   only one Pod.
curl http://c1-cp1:$NODEPORT
curl http://c1-node1:$NODEPORT
curl http://c1-node2:$NODEPORT
curl http://c1-node3:$NODEPORT

# And a Node port Service is also listening on a Cluster IP, in fact the Node Port
#   traffic is routed to the ClusterIP
echo $CLUSTERIP:$PORT
curl http://$CLUSTERIP:$PORT

# Let's delete that Service
kubectl delete service hello-world-nodeport
kubectl delete deployment hello-world-nodeport


# 3 - Creating LoadBalancer Services in Azure or any cloud
# Switch contexts into AKS, we created this cluster together in 'Kubernetes Installation
#   and Configuration Fundamentals'
# I've added a script to create a GKE and AKS cluster in this course's downloads

**************
az login
# az account set --subscription "{SUBSCRIPTION}"

az group create --name "Kubernetes-Cloud" --location centralus

az aks get-versions --location centralus -o table

# Let's create our AKS managed cluster.
az aks create \
    --resource-group "Kubernetes-Cloud" \
    --generate-ssh-keys \
    --name CSCluster \
    --node-count 3

az aks get-credentials --resource-group "Kubernetes-Cloud" --name CSCluster

kubectl config get-contexts

kubectl config use-context 'CSCluster'

kubectl get nodes

***************

# Let's create a Deployment
kubectl create deployment hello-world-loadbalancer \
    --image=psk8s.azurecr.io/hello-app:1.0

# Create a LoadBalancer Service
kubectl expose deployment hello-world-loadbalancer \
    --port=80 --target-port=8080 --type LoadBalancer

# Can take a minute for the LoadBalancer to provision and get a public IP, you'll see
#   EXTERNAL-IP as <pending>
kubectl get service --watch

LOADBALANCERIP=$(kubectl get service hello-world-loadbalancer -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
curl http://$LOADBALANCERIP:$PORT

# The LoadBalancer, which is "outside" your cluster, sends traffic to the NodePort
#   Service, which sends it to the ClusterIP to get to your Pods
# Your cloud LoadBalancer will have health probes checking the health of the NodePort
#   service on the real Node IPs
# This isn't the health of our application, that still needs to be configured via
#   readiness/liveness probes and maintained by your Deployment configuration
kubectl get service hello-world-loadbalancer

# Clean up the resources from this demo
kubectl delete deployment hello-world-loadbalancer
kubectl delete service hello-world-loadbalancer

az group delete --name Kubernetes-Cloud 

# Let's switch back to our local cluster
kubectl config use-context kubernetes-admin@kubernetes
