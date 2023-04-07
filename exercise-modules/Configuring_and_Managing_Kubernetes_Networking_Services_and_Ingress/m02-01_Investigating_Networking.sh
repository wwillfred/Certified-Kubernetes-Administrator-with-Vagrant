m02-01 Investigating Kubernetes Networking

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/02_Kubernetes_Networking_Fundamentals

# Local Cluster - Calico CNI Plugin
# Get all Nodes and their IP information, INTERNAL-IP is the real IP of the Node
kubectl get nodes -o wide

# Let's deploy a basic workload, hello-world with 3 Replicas to create some Pods on the Pod
#   network.
kubectl apply -f Deployment.yaml

# Get all Pods, we can see each Pod has a unique IP on the Pod Network.
# Our Pod Network was defined in the first course and we chose 192.168.0.0/16
kubectl get pods -o wide

# Let's hop inside a Pod and check out its netwroking, a single interface and IP on the Pod
#   Network
# The line below will get a list of Pods from the label query and return the name of the
#   first Pod in the list
PODNAME=$(kubectl get pods --selector=app=hello-world -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- /bin/sh
ip addr
exit

# For the Pod on c1-node1, let's find out how traffic gets from c1-cp1 to c1-node1 to get to
#   that Pod.

# Look at the annotations, specifically the annotation projectcalico.org/IPv4IPIPTunnelAddr: 192.168.19.64...your IP may vary
# Check out the Addresses: InternalIP, that's the real IP of the Node.
# Pod IPs are allocated from the network Pod Network which is configurable in Calico, it's
#   controlling the IP allocation.
# Calico is using tunnel interfaces to implement the Pod Network model.
# Traffic going to other Pods will be sent into the tunnel interface and directly to the 
#   Node running the Pod.
# For more info on Calico's operations https://docs.projectcalico.org/reference/cni-plugin/configuration
kubectl describe node c1-cp1 | more

# Let's see how the traffic gets to c1-node1 from c1-cp1
# Via routes on the node, to get to c1-node1 traffic goes into tun10/192.168.19.64...your
#   IP may vary
# Calico handles the tunneling and sends the packet to the correct Node to be sent on into
#   the Pod running on that Node based on the defined rountes
# Follow each route, showing how to get to the Pod IP, it will need to go to the tun0
#   interface.
# The cali* interfaces are for each Pod on the Pod network, traffic destined for the Pod 
#   IP will have a 255.255.255.255 route to this interface.
kubectl get pods -o wide
route

# The local tun10 is 192.168.19.64, packets destined for Pods running on c1-cp1 will be
#   routed to this interface and get encapsulated then sent to the destination node for
#   de-encapsulation
ip addr

# Log into c1-node1 and look at the interfaces, there's tun10 192.168.222.192...this is
#   this node's tunnel interface
exit
vagrant ssh c1-node1

# This tun10 is the destination interface, on this Node it is 192.168.222.192, which we
#   saw on the route listing on c1-cp1
ip addr

# All Nodes will have routes back to the other Nodes via the tun10 interface
route

# Exit back to c1-cp1
exit


# Azure Kubernetes Service - kubenet
# Get all Nodes and their IP information, INTERNAL-IP is the real IP of the Node
vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/02_Kubernetes_Networking_Fundamentals


# Azure Kubernetes Service - kubenet
# Get all Nodes and their IP information, INTERNAL-IP is the real IP of the Node
# sudo apt-get update
# sudo apt-get install azure-cli
# az login
# az group create --name "Kubernetes-Cloud" --location centralus
# az aks get-versions --location centralus -o table
# az aks create \
#     --resource-group "Kubernetes-Cloud" \
#     --generate-ssh-keys \
#     --name CSCluster \
#     --node-count 3 
# az aks get-credentials --resource-group "Kubernetes-Cloud" --name CSCluster
# kubectl config get-contexts
kubectl config use-context 'CSCluster'

# Let's deploy a basic workload, hello-world with3 replicas
kubectl apply -f Deployment.yaml

# Note the INTERNAL-IP, these are on the virtual network in Azure, the real IPs of the
#   underlying VMs
kubectl get nodes -o wide

# This time we're using a different network plugin, kubenet. It's based on routes/bridges
#   rather than tunnels. Let's explore
# Check out Addresses and PodCIDR
kubectl describe nodes | more
