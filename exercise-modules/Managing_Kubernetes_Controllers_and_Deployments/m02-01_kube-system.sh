# m02-01 kube-system

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Managing_Kubernetes_Controllers_and_Deployments/02

# Demo 1 - Examining System Pods and their Controllers

# Inside the kube-system namespace, there's a collection of controllers supporting parts of the cluster's control plane
# How'd they get started since there's no cluster when they need to come online?
# Static Pod Manifests

kubectl get --namespace kube-system all

# Let's look more closely at one of those deployments, requiring 2 pods up and running at all times.
kubectl get --namespace kube-system deployments coredns

# Daemonset Pods run on every node in the cluster by default, as new nodes are added these will be deployed to those nodes.
# There's a Pod for our Pod network, calico and one for the kube-proxy.
kubectl get --namespace kube-system daemonset

# We have 4 nodes, that's why for each daemonset they have 4 Pods.
kubectl get nodes
