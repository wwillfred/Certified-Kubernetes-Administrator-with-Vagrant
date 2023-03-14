# m03-03 Private Container Registry-ctr

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Storage_and_Scheduling/03_Configuration_as_Data_Environment_Variables_Secrets_and_ConfigMaps

# Demo 1 - Pulling a Container from a Private Container Registry

# To create a private repository in a container registry, follow the directions here
# https://docs.docker.com/docker-hub/repos/#private-repositories

# Let's pull down a hello-world image from gcr
sudo ctr images pull gcr.io/google-samples/hello-app:1.0

# Let's get a listing of images from ctr to confirm our image is downloaded
sudo ctr images list

# Tagging our image in the format [your registry], [image] and [tag]
# You'll be using your own repository, so update that information here.
#  source_ref: gcr.io/google-samples/hello-app:1.0	# this is the image pulled from gcr
#  target_ref: docker.io/nocentino/hello-apps:ps	# this is the image you want to push
							# into your private repository
sudo ctr images tag gcr.io/google-samples/hello-app:1.0 docker.io/[docker username]/[repository]:[tag]

# Now push that locally tagged image into our private registry at docker hub
# You'll be using your own repository, so update that information here and specify your $USERNAME
# You will be prompted for the password to your repository
sudo ctr images push docker.io/[docker username]/[repository]:[tag] --user $USERNAME

# Create our secret that we'll use for our image pull...
# Update the parameters to match the information for your repository including the servername,
#   username, password, and email.
kubectl create secret docker-registry private-reg-cred \
    --docker-server=https://index.docker.io/v2/ \
    --docker-username=$USERNAME \
    --docker-password=$PASSWORD \
    --docker-email=$EMAIL

# Ensure the image doesn't exist on any of our nodes...or else we can get a false positive
#   since our image would be cached on the node.
# Caution, this will delete *ANY* image that begins with hello-app
exit
vagrant ssh c1-node1
sudo ctr --namespace k8s.io image ls "name~=hello-app" -q | sudo xargs ctr --namespace k8s.io image rm
exit
vagrant ssh c1-node2
sudo ctr --namespace k8s.io image ls "name~=hello-app" -q | sudo xargs ctr --namespace k8s.io image rm
exit
vagrant ssh c1-node3
sudo ctr --namespace k8s.io image ls "name~=hello-app" -q | sudo xargs ctr --namespace k8s.io image rm
exit

# Create a deployment using imagePullSecret in the Pod Spec.
kubectl apply -f deployment-private-registry.yaml

# Check out Containers and events section to ensure the container was actually pulled.
# This is why I made sure they were deleted from each Node above.
kubectl describe pods hello-world

# Clean up after our demo, remove the images from c1-cp1
kubectl delete -f deployment-private-registry.yaml
kubectl delete secret private-reg-cred
sudo ctr images remove docker.io/{username}/{registry}:{tag}
sudo ctr images remove gcr.io/google-samples/hello-app:1.0
