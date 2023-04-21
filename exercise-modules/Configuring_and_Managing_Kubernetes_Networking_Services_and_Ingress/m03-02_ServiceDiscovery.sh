m03-02 Service Discovery

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Networking_Services_and_Ingress/03_Configuring_and_Managing_Application_Access_with_Services

# Cluster DNS

# Let's create a deployment in the default namespace
kubectl create deployment hello-world-clusterip --image=psk8s.azurecr.io/hello-app:1.0

# Let's expose that deployment
kubectl expose deployment hello-world-clusterip \
    --port=80 --target-port=8080 --type ClusterIP

# We can use nslookup or dig to investigate the DNS record, its CNAME @10.96.0.10 is the
#   cluster IP of our DNS Server
kubectl get service kube-dns --namespace kube-system
