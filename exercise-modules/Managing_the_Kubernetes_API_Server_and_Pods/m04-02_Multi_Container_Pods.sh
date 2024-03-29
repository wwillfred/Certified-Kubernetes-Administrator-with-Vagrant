# m04-02: Multi-Container Pods

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Managing_the_Kubernetes_API_Server_and_Pods/04_Running_and_Managing_Pods

# Review the code for a multi-container pod, the volume webcontent is an eptyDir...essentially a temporary file system.
# This is mounted in the containers at mountPath, in two different locations inside the container.
# As producer writes data, consumer can see it immediately since it's a shared file system.
more multicontainer-pod.yaml

# Let's create our multi-container Pod.
kubectl apply -f multicontainer-pod.yaml

# Let's connect to our Pod...not specifying a name defaults to the first container in the configuration
kubectl exec -it multicontainer-pod -- /bin/sh
ls -la /var/log
tail /var/log/index.html
exit

# Let's specify a container name and access the consumer container in our Pod
kubectl exec -it multicontainer-pod --container consumer -- /bin/sh
ls -la /usr/share/nginx/html
tail /usr/share/nginx/html/index.html
exit

# This application listens on port 80, we'll forward from 8080->80
kubectl port-forward multicontainer-pod 8080:80 &
curl http://localhost:8080

# Kill our port-forward.
fg
ctrl+c

kubectl delete pod multicontainer-pod
