m04-01 ingress loadbalancer

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/04_Configuring_and_Managing_Application_Access_with_Ingress

# Check out 1-ingress-nodeport.sh for the on-prem demos

# Demo 1 - Deploying an ingress controller
# For our Ingress Controller, we're going to go with nginx, widely available and easy to
#   use.
# Follow this link here to find a manifest for nginx Ingress Controller for various
#   infrastructures, Cloud, Bare Metal, EKS and more.
# We have to choose a platform to deploy in...we can choose Cloud, Bare-metal (which we can
#   use in our local cluster) and more.
https://kubernetes.github.io/ingress-nginx/deploy/

# Cloud: Azure (Same for GCE-GKE) This Ingress Controller will be exposed as a LoadBalancer
#   service on a real public IP.
# Let's make sure we're in the right context and deploy the manifest for the Ingress
#   Controller found in the link just above (around line 9).
az login
az group create --name "Kubernetes-Cloud" --location centralus 
az aks create \
    --resource-group "Kubernetes-Cloud" \
    --generate-ssh-keys \
    --name CSCluster \
    --node-count 3

az aks get-credentials --resource-group "Kubernetes-Cloud" --name CSCluster
kubectl config get-contexts
kubectl config use-context 'CSCluster'
kubectl get nodes

kubectl apply -f ./cloud/deploy.yaml

# Using this manifest, the Ingress Controller is in the ingress-nginx namespace but it will
#   monitor for Ingresses in all namespaces by default. If can be scoped to monitor a
#   specifc namespace if needed.

# Check the status of the Pods to see if the ingress controller is online.
kubectl get pods --namespace ingress-nginx

# Now let's check to see if the service is online. This is type LoadBalancer, so do you have
#   an EXTERNAL-IP?
kubectl get services --namespace ingress-nginx

# Check out the ingressclass nginx...we have not set the is-default-class so in each of our
#   Ingresses we will need to specify an ingressclassname
kubectl describe ingressclasses nginx
# kubectl annotate ingressclass nginx "ingressclass.kubernetes.io/si-default-class=true"


# Demo 2 - Single Service
# Create a Deployment, scale it to 2 replicas and expose it as a Service.
# This Service will be ClusterIP and we'll expose this Service via the Ingress.
kubectl create deployment hello-world-service-single --image=psk8s.azurecr.io/hello-app:1.0
kubectl scale deployment hello-world-service-single --replicas=2
kubectl expose deployment hello-world-service-single --port=80 --target-port=8080 --type=ClusterIP

# Create a single Ingress routing to the one backend service on the Service port 80
#   listening on all hostnames
kubectl apply -f ingress-single.yaml

# Get the status of the Ingress. It's routing for all host names on that public IP on port
#   80
# This IP will be the same as the EXTERNAL-IP of the Ingress controller...will take a
#   second to update
# If you don't define an ingressclassname and don't have a default ingress class the
#   address won't be updated.
kubectl get ingress --watch
kubectl get services --namespace ingress-nginx

# Notice the backends are the Service's Endpoints...so the traffic is going straight from
#   the Ingress Controller to the Pod, cutting out the kube-proxy hop.
# Also notice, the default backend is the same Service, that's because we didn't define
#   any rules, and we just populated ingress.spec.backend. We're going to look at rules
#   next...
kubectl describe ingress ingress-single

# Access the application via the exposed ingress on the public IP
INGRESSIP=$(kubectl get ingress -o jsonpath='{ .items[].status.loadBalancer.ingress[].ip }')
curl http://$INGRESSIP



# Demo 3 - Multiple Services with path-based routing
# Let's create two additional services
kubectl create deployment hello-world-service-blue --image=psk8s.azurecr.io/hello-app:1.0
kubectl create deployment hello-world-service-red --image=psk8s.azurecr.io/hello-app:1.0

kubectl expose deployment hello-world-service-blue --port=4343 --target-port=8080 --type=ClusterIP
kubectl expose deployment hello-world-service-red --port=4242 --target-port=8080 --type=ClusterIP

# Let's create an ingress with paths each routing to different backend services.
kubectl apply -f ingress-path.yaml

# We now have two, one for all hosts and the other for our defined host with two paths
# The Ingress controller is implementing these ingresses and we're sharing the one public
#   IP, don't proceed until you see # the address populated for your ingress
kubectl get ingress --watch

# We can see the host, the path, and the backends.
kubectl describe ingress ingress-path

# Our ingress on all hosts is still routing to Service single, since we're accessing the 
#   URL with an IP and not a domain name or host header.
curl http://$INGRESSIP/

# Our paths are routing to their correct Services, if we specify a host header or use a
#   DNS name to access the Ingress. That's how the rule will route the request.
curl http://$INGRESSIP/red --header 'Host: path.example.com'
curl http://$INGRESSIP/blue --header 'Host: path.example.com'

# If we don't specify a path we'll get a 404 while specifying a host header.
# We'll need to configure a path and backend for / or define a default backend for the
#   service
curl http://$INGRESSIP/      --header 'Host: path.example.com'

# Let's add a backend to the Ingress listening on path.example.com pointing to the single
#   service
kubectl apply -f ingress-path-backend.yaml

# We can see the default backend, and in the Rules, the host, the path, and the backends
kubectl describe ingress ingress-path

# Now we'll hit the default backend Service, single
curl http://$INGRESSIP/ --header 'Host: path.example.com'


# Demo 4 - Name-based virtual hosts
# Now, let's route traffic to the Services using name-based virtual hosts, rather than
#   paths, wait for ADDRESS to be populated
kubectl apply -f ingress-namebased.yaml
kubectl get ingress --watch

curl http://$INGRESSIP/ --header 'Host: red.example.com'
curl http://$INGRESSIP/ --header 'Host: blue.example.com'


# TLS Example
# 1 - Generate a certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout tls.key -out tls.crt -subj "/C=US/ST=ILLIONOIS/L=CHICAGO/O=IT/OU=IT/CN=tls.example.com"

# 2 - Create a Secret with the key and the certificate
kubectl create secret tls tls-secret --key tls.key --cert tls.crt

# 3 - Create an Ingress using the certificate and key. This uses HTTPS for both / and /red
kubectl apply -f ingress-tls.yaml

# Check the status...do we have an IP?
kubectl get ingress --watch

# Test access to the hostname...we need --resolve because we haven't registered the DNS
#   name
# TLS is a layer lower than host headers, so we have to specify the correct DNS name.
curl https://tls.example.com:443 --resolve tls.example.com:443:$INGRESSIP --insecure --verbose


# Clean up from our demo
kubectl delete ingresses ingress-path
kubectl delete ingresses ingress-tls
kubectl delete ingresses ingress-namebased
kubectl delete deployment hello-world-service-single
kubectl delete deployment hello-world-service-red
kubectl delete deployment hello-world-service-blue
kubectl delete service hello-world-service-single
kubectl delete service hello-world-service-red
kubectl delete service hello-world-service-blue
kubectl delete secret tls-secret
rm tls.crt
rm tls.key

# Delete the Ingress, Ingress Controller, and other configuration elements
kubectl delete -f ./cloud/deploy.yaml

az group delete --name Kubernetes-Cloud
