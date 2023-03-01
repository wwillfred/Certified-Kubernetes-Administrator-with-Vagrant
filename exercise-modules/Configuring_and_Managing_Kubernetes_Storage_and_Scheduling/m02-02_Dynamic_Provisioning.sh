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

cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/02_Configuring_and_Managing_Storage_in_Kubernetes

# Demo 1 - 
