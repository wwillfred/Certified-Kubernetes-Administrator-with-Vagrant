m04-02 - Jobs Cron Jobs

vagrant ssh c1-cp1
cd /vagrant/Managing_Kubernetes_Controllers_and_Deployments/04

# Demo 1 - Executing tasks with Jobs, check out the file job.yaml
# Ensure you define a restartPolicy, the default of a Pod is Always, which is not compatible
# with a Job.
# We'll need OnFailure or Never, let's look at OnFailure
kubectl apply -f job.yaml


# Follow job status with a watch
kubectl get job --watch &


# Get the list of Pods, status is Completed and Ready is 0/1
kubectl get pods


# Let's get some more details about the job...labels and selectors, Start Time, Duration
# and Pod Statuses
kubectl describe job hello-world-job


# Get the logs from stdout from the Job Pod
kubectl get pods -l job-name=hello-world-job
kubectl logs PASTE_POD_NAME_HERE


# Our Job is completed, but it's up to us to delete the Pod or the Job.
kubectl delete job hello-world-job


# Which will also delete its Pods
kubectl get pods



# Demo 2 - Show restartPolicy in action..., check out backoffLimit: 2 and restart Policy:
# Never
# We'll want to use Never so our pods aren't deleted after backoffLimit is reached.
kubectl apply -f job-failure-OnFailure.yaml


# Let's look at the pods, enters a backoffloop after 2 crashes
kubectl get pods --watch


# The pods aren't deleted so we can troubleshoot here if needed.
kubectl get pods


# And the job won't have any completions and it doesn't get deleted
kubectl get jobs

# So let's review what the job did...Events, created...then deleted. Pods status, 3 Failed.
kubectl describe jobs | more


# Clean up this job
kubectl delete jobs hello-world-job-fail
kubectl get pods



# Demo 3 -
