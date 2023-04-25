m04-01 ingress loadbalancer

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/04_Configuring_and_Managing_Application_Access_with_Ingress

# Check out 1-ingress-nodeport.sh for the on-prem demos

# Demo 1 - Deploying an ingress controller
# For our Ingress Controller, we're going to go with nginx, widely available and easy to
#   use.
# Follow this link here to find a manifest for nginx Ingress Controller for various
#   infrastructures, Cloud, Bare Metal, EKS and more.
# We have to choose a platform to deploy in...we can choose Cloud, Bare-metal (which we can
#   use in our local cluster) and more.
https://kubernetes.github.io/ingress-nginx/deploy/

# Cloud: Azure (Same for GCE-GKE) This Ingress Controller will be exposed as a LoadBalancer
#   service on a real public IP.
# Let's make sure we're in the right context and deploy the manifest for the Ingress
#   Controller found in the link just above (around line 9).
az login
az group create --name "Kubernetes-Cloud" --location centralus 
az aks create \
    --resource-group "Kubernetes-Cloud" \
    --generate-ssh-keys \
    --name CSCluster \
    --node-count 3

az aks get-credentials --resource-group "Kubernetes-Cloud" --name CSCluster
kubectl config get-contexts
kubectl config use-context 'CSCluster'
kubectl get nodes

kubectl apply -f ./cloud/deploy.yaml

# Using this manifest, the Ingress Controller is in the ingress-nginx namespace but it will
#   monitor for Ingresses in all namespaces by default. If can be scoped to monitor a
#   specifc namespace if needed.

# Check the status of the Pods to see if the ingress controller is online.
kubectl get pods --namespace ingress-nginx

# Now let's check to see if the service is online. This is type LoadBalancer, so do you have
#   an EXTERNAL-IP?
kubectl get services --namespace ingress-nginx

# Check out the ingressclass nginx...we have not set the is-default-class so in each of our
#   Ingresses we will need to specify an ingressclassname
kubectl describe ingressclasses nginx
# kubectl annotate ingressclass nginx "ingressclass.kubernetes.io/si-default-class=true"
