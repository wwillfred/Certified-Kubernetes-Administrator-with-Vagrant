# m02-01 Dynamic provisioning

vagrant ssh c1-cp1

# Demo 0 - Azure Setup
# If you don't have your Azure Kubernetes Service Cluster available, follow these instructions:

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

# Set our current context to the Azure context
kubectl config use-context CSCluster

# Run a command to communicate with our cluster
kubectl get nodes

# Get a list of running pods. We'll look at the system pods since we don't have
# anything running.
# Since the API Server is HTTP based...we can operate our cluster over the
# internet...essentially the same as if it was local using kubectl.
kubectl get pods --all-namespaces

cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/02_Configuring_and_Managing_Storage_in_Kubernetes

# Demo 1 - StorageClasses and Dynamic Provisioning in Azure
# Let's create a disk in Azure. Using a dynamic provisioner and storage class

# Check out our list of available storage classes, which one is default?
# Notice the Provisioner, Parameters and ReclaimPolicy.
kubectl get StorageClass
kubectl describe StorageClass default
kubectl describe StorageClass managed-premium

# Let's create a Deployment of an nginx pod with a ReadWriteOnce disk.
# We create a PVC and a Deployment that creates Pods that use that PVC
kubectl apply -f AzureDisk.yaml

# Check out the Access Mode, Reclaim Policy, Status, Claim and StorageClass
kubectl get PersistentVolume

# Check out the AccessMode on the PersistentVolumeClaim, status is Bound and
# its Volume is the PV dynamically provisioned
kubectl get PersistentVolumeClaim

# Let's see if our single pod was created (the Status can take a second to transition to Running)
kubectl get pods

# Clean up when we're finished and set our context back to our local cluster
kubectl delete deployment nginx-azdisk-deployment
kubectl delete PersistentVolumeClaim pvc-azure-managed


# Demo 2 - Defining a custom StorageClass in Azure
kubectl apply -f CustomStorageClass.yaml

# Get a list of the current StorageClasses kubectl get StorageClass.
kubectl get StorageClass

# A closer look at the SC, you can see the Reclaim Policy is Delete since we
# didn't set it in our StorageClass yaml.
kubectl describe StorageClass managed-standard-ssd

# Let's use our new StorageClass
kubectl apply -f AzureDiskCustomStorageClass.yaml

# And take a closer look at our new Storage Class, Reclaim Policy Delete
kubectl get PersistentVolumeClaim
kubectl get PersistentVolume

# Clean up our demo resources
kubectl delete deployment nginx-azdisk-deployment-standard-ssd
kubectl delete PersistentVolumeClaim pvc-azure-standard-ssd
kubectl delete StorageClass managed-standard-ssd

# Switch back to our local cluster from Azure
kubectl config use-context kubernetes-admin@kubernetes
az group delete --name "Kubernetes-Cloud"
