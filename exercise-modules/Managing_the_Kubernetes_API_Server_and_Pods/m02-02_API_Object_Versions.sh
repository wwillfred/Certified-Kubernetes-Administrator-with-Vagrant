# m02-02

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Managing_the_Kubernetes_API_Server_and_Pods/02-Using_the_Kubernetes_API 

# Let's ask the API Server for the API Resources it knows about.
kubectl api-resources | more

# A list of the objects available in a specific API Group such as apps...try using another API Grup...
kubectl api-resources --api-group=apps

# We can use explain to dig further into a specific API Resource and version
# Check out KIND and VERSION, we'll see the API Group in the from group/version
# Deployments recently moved from apps/v1beta1 to apps/v1
kubectl explain deployment --api-version apps/v1 | more

# Print the supported API versions and Groups on the API server again in the form group/version.
# Here we see several API Groups have several versions in various stages of releases...such as v1, v1beta1, v2beta1...and so on.
kubectl api-versions | sort | more
