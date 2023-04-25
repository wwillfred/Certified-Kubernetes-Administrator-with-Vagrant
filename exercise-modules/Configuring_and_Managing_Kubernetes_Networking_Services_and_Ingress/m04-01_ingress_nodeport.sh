m04-01 ingress nodeport

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/04_Configuring_and_Managing_Application_Access_with_Ingress

#Check out 1-ingress-loadbalancer.sh for the cloud demos

#Demo 1 - Deploying an ingress controller
#For our Ingress Controller, we're going to go with nginx, widely available and easy to use.
#Follow this link here to find a manifest for nginx Ingress Controller for various infrastructures, Cloud, Bare Metal, EKS and more.
#We have to choose a platform to deploy in...we can choose Cloud, Bare-metal (which we can use in our local cluster) and more.
https://kubernetes.github.io/ingress-nginx/deploy/
