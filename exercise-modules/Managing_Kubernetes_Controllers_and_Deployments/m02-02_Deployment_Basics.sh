m02-02: Deployment Basics

ssh c1-cp1
cd /vagrant/Managing_Kubernetes_Controllers_and_Deployments/02

# Demo 2 Creating Deployment Imperatively, with kubectl create,
# you have lots of options available to you such as image, container ports, and replicas
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0
kubectl scale deployment hello-world --replicas=5

# These two commands can be combined into one command if needed
# kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0 --replicas=5

# Check out the status of our imperative deployment
kubectl get deployment

# Now let's delete that and move towards declarative configuration
kubectl delete deployment hello-world

# Demo 1.b - Declaratively
# Simple deployment
# Let's start off declaratively creating a deployment with a service
kubectl apply -f deployment.yaml

#  
