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
