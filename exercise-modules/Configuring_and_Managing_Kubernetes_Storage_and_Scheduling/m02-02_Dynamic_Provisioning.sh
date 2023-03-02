# m02-01 Dynamic provisioning

vagrant ssh c1-cp1

# Demo 0 - Azure Setup
# If you don't have your Azure Kubernetes Service Cluster available, follow the script
# in CreateAKSCluster.sh

# Ensure Azure CLI command line utilities are installed
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list 

curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

sudo apt-get update
sudo apt-get install azure-cli

# Log into our subscription
az login
az account set --subscription "Demonstration Account"

# Create a resource group for the services we're going to create
az group create --name "Kubernetes-Cloud" --location centralus

# Let's get a list of the versions available to us
az aks get-versions --location centralus -o table

# Let's check out some of the options available to us when creating our managed cluster
az aks create -h | more

# Let's create our AKS managed cluster.
az aks create \
  --resource-group "Kubernetes-Cloud" \
  --generate-ssh-keys \
  --name CSCluster \
  --node-count 3 # default Node count is 3

# Get our cluster credentials and merge the configuration into our existing config file
# This will allow us to connect to this system remotely using certificate-based user
# authentication.
az aks get-credentials --resource-group "Kubernetes-Cloud" --name CSCluster

# List our currently available contexts
kubectl config get-contexts


cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/02_Configuring_and_Managing_Storage_in_Kubernetes

# Demo 1 - 
