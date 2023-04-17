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

# Demo 3 - let's get a Pod's DNS A record and a Service's A record
# Create a Deployment and a Service
kubectl apply -f Deployment.yaml

# Get the Pod's and their IP addresses
kubectl get pods -o wide

# Get the address of our DNS Service again... just in case
SERVICEIP=$(kubectl get service --namespace kube-system kube-dns -o jsonpath='{ .spec.clusterIP }')

# For one of the Pods replace the dots in the IP address with dashes, for example 192.168.206.68 becomes 192-168-206-68
# We'll look at some additional examples of Service Discovery in the next module too.
nslookup 192-168-206-[XX].default.pod.cluster.local $SERVICEIP

# Our Services also get DNS A records
# There's more on Service A records in the next demo
kubectl get service
nslookup hello-world.default.svc.cluster.local $SERVICEIP

# Clean up our resources
kubectl delete -f Deployment.yaml


# TODO for the viewer...you can use this technique to verify your DNS forwarder 
#   configuration from the first demo in this file.
# Recreate the custom configuration by applying the custom configmap defined in
#   CoreDNSConfigCustom.yaml
# Logging in CoreDNS will log the query, but not which forwarder it was sent to.
# We can use tcpdump to listen to the packets on the wire to see where the DNS queries are
#   being sent to.

kubectl apply -f CoreDNSConfigCustom.yaml

# Find the name of a Node running one of the DNS Pods running...so we're going to observe
#   DNS queries there.
DNSPODNODENAME=$(kubectl get pods --namespace kube-system --selector=k8s-app=kube-dns -o jsonpath='{ .items[0].spec.nodeName }')
echo $DNSPODNODENAME

# Let's log into THAT node running the DNS Pod and start a tcpdump to watch our DNS queries
#   in action.
# Your interface (-i) name may be different
ssh $DNSPODNODENAME
sudo tcpdump -i eth0 port 53 -n

# In a second terminal, let's test our DNS configuration from a Pod to make sure we're
#   using the configured forwarder.
# When this Pod starts, it will point to our cluster DNS service.
# Install dnsutils for nslookup and dig
vagrant ssh c1-cp1
kubectl run -it --rm debian --image=debian
apt-get update && apt-get install dnsutils -y

# In our debian Pod let's look at the DNS config and run two test DNS queries
# The nameserver will be your cluster DNS service cluster IP.
# We'll query two domains to generate traffic for our tcpdump
cat /etc/resolv.conf
nslookup www.pluralsight.com
nslookup www.centinosystems.com

# Switch back to our second terminal and review the tcpdump, confirming each query is going
#   to the correct forwarder
# Here is some example output...www.pluralsight.com is going to 1.1.1.1 and 
#   centinosystems.com is going to 9.9.9.9
# 172.16.94.13.63841 > 1.1.1.1.53: 24753+ A? www.pluralsight.com. (37)
# 172.16.94.134253 > 9.9.9.9.53: 29485+ [1au] A? www.centinosystems.com. (63)

# Exit the tcpdump
ctrl+c

# Log out of the Node, back onto c1-cp1
exit

# Switch sessions and break out of our Pod, and it will be deleted
exit

# Exit out of our second SSH session and get a shell back on c1-cp1
exit

kubectl delete -f CoreDNSConfiCustom.yaml
