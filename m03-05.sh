# Module 3

## Creating a Cluster in the Cloud with Azure Kubernetes Service

# This demo will be run from c1-cp1 since kubectl is already installed there.
# This can be run from any system that has the Azure CLI client installed.

vagrant ssh c1-cp1

#Ensure Azure CLI command line utilitles are installed
#https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

# Install the gpg key for Microsoft's repository
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

sudo apt-get update
sudo apt-get install azure-cli

# Log into our subscription
az login
az account set --subscription SUBSCRIPTION_NAME

# Create a resource group for the services we're going to create
az group create --name "Kubernetes-Cloud" --location centralus

# Let's get a list of the versions available to us
az aks get-versions --location centralus -o table

# Let's create our AKS managed cluster. Use --kubernetes-version to specify a version.
az aks create \
    --resource-group "Kubernetes-Cloud" \
    --generate-ssh-keys \
    --name CSCluster \
    --node-count 3 #default Node count is 3

# If we didn't already have kubectl installed locally we would download it like this
# az aks install-cli

# Get our cluster credentials and merge the configuration into our existing config file.
# This will allow us to connect to this system remotely using certificate-based user authentication.
az aks get-credentials --resource-group "Kubernetes-Cloud" --name CSCluster

# List our currently available contexts
# We now have two contexts, as we've just downloaded the credentials to our AKS cluster.
kubectl config get-contexts

# Our current context is already set to the Azure context, but in case it wasn't for some reason:
kubectl config use-context CSCluster

# Run a command to communicate with our cluster.
# We notice that there's no Control Plane node listed, as AKS abstracts that away for us.
kubectl get nodes

# Get a list of running pods, we'll look at the system pods since we don't have anything running.
# Since the API Server is HTTP-based...we can operate our cluster over the internet...essentially the same as if it was local using kubectl.
# Because AKS abstracts away the Control Plane node for us, we won't see any of the Control Plane pods like API_Server, etcd, controller manager, etc.
# We will however see some pods that are unique to AKS like coredns, kube-proxy etc.
kubectl get pods --all-namespaces

# Let's switch our context back to our local cluster
kubectl config use-context kubernetes-admin@kubernetes

# Just to make sure, we can use check the nodes
kubectl get nodes

# And we can tear down our resource group
az group delete -n "Kubernetes-Cloud" -y
