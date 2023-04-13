m02-02 Investigating Networking

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/02_Kubernetes_Networking_Fundamentals

# 1. Investigating the Cluster DNS Service
# It's deployed as a Service in the cluster with a Deployment in the kube-system namespace
kubectl get service --namespace kube-system

# Two Replicas, Args injecting the location of the config file which is backed by ConfigMap
#   mounted as a Volume
kubectl describe deployment coredns --namespace kube-system | more

# The configmap defining the CoreDNS configuration and we can see the default forwarder is
#   /etc/resolv.conf
kubectl get configmaps --namespace kube-system coredns -o yaml | more


# 2. Configuring CoreDNS to use custom Forwarders, spaces not tabs!
# Defaults use the Node's DNS Servers for forwarders
# Replaces forward . /etc/resolv.conf with forward . 1.1.1.1
# Add a conditional domain forwarder for a specific domain
# ConfigMap will take a second to update the mapped file and the config to be reloaded
kubectl apply -f CoreDNSConfigCustom.yaml --namespace kube-system

# How will we know when the CoreDNS configuration file is updated in the Pod?
# You can tail the log looking for the reload the configuration file...this can take a 
#   minute or two
# We're looking for "Reloading complete"
# Also look for any errors post configuration. Seeing [WARNING] No files matching
#   import glob pattern: custom/*.override is normal
kubectl logs --namespace kube-system --selector 'k8s-app=kube-dns' --follow

# Run some DNS queries against the kube-dns service cluster ip to ensure everything works...
SERVICEIP=$(kubectl get service --namespace kube-system kube-dns -o jsonpath='{ .spec.clusterIP }')
nslookup www.pluralsight.com $SERVICEIP
nslookup www.centinosystems.com $SERVICEIP

# On c1-cp1, let's put the default configuration back, using . forward /etc/resolv.conf
kubectl apply -f CoreDNSConfigDefault.yaml --namespace kube-system


#3. Configuring Pod DNS client Configuration
kubectl apply -f DeploymentCustomDns.yaml

# Let's check the DNS configuration of a Pod created with that configuration
# This line will grab the first Pod matching the defined selector
PODNAME=$(kubectl get pods --selector=app=hello-world-customdns -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- cat /etc/resolv.conf

# Clean up our resources
kubectl delete -f DeploymentCustomDns.yaml
