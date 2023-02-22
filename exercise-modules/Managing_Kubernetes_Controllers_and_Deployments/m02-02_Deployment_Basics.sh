m02-02: Deployment Basics

ssh c1-cp1
cd /vagrant/declarative-config-files/Managing_Kubernetes_Controllers_and_Deployments/02

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

# Check out the status of our deployment, which creates the ReplicaSet, which creates our Pods
kubectl get deployments hello-world

# The first ReplicaSet created in our deployment, which has the responsibility
# of maintaining the desired state of our application but starting and keeping 5 pods online.
# In the name of the ReplicaSet is the pod-template-hash
kubectl get replicasets  

# The actual pods as part of this ReplicaSet, we know these pods belong to the
# replicaset because of the pod-template-hash in the name
kubectl get pods

# But also by looking at the 'Controlled By' property
kubectl describe pods | head -n 15

# It's the job of the deployment-controller to maintain state. 
# Let's look at it a little closer
# The selector defines which pods are a member of this deployment.
# Replicas define the current state of the deployment
# We'll dive into what each one of these means later in the course.
# In Events, you can see the creation and scaling of the replica set to 5
kubectl describe deployment

# Remove our resources
kubectl delete deployment hello-world
kubectl delete service hello-world
