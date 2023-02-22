m03-01: Deployments

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Managing_Kubernetes_Controllers_and_Deployments/03

# Demo 1 - Updating a Deployment and checking our rollout status
# Let's start off with rolling out v1
kubectl apply -f deployment.yaml

# Check the status of the deployment
kubectl get deployment hello-world

# Now let's apply that deployment, run both this and the next command at the
# same time.
kubectl apply -f deployment.v2.yaml

# Let's check the status of that rollout, while the command blocking your
# deployment is in the Progressing status.
kubectl rollout status deployment hello-world

# Expect a return code of 0 from kubectl rollout status...that's how we know
# we're in the Complete status.
echo $?

# Let's walk through the description of the deployment..
# Check out Replicas, Conditions, and Events OldReplicaSet (will only be
# populated during a rollout) and NewReplicaSet
# Conditions (more information about our objects state):
#	Available 	True	MinimumReplicasAvailable
#	Progressing	True	NewReplicaSetAvailable (when true, deployment
# is still progressing or complete)
kubectl describe deployments hello-world

# Both ReplicaSets remain, and that will become very useful shortly when we
# use a rollback :)
kubectl get replicaset

# The NewReplicaSet, check out labels, replicas, status and pod-template-hash
kubectl describe replicaset hello-world-75c5949f5b

# The OldReplicaSet, check out labels, replicas, status, and pod-template-hash
kubectl describe replicaset hello-world-7c649d8c6f
