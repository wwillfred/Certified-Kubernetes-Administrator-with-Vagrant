m02-01 Authentication

vagrant ssh c1-cp1
cd /vagrant/declarative-config-files/Configuring_and_Managing_Kubernetes_Security/02_Kubernetes_Security_Fundamentals

# 1 - Investigating Certificate-based authentication
# We're using certificates to authenticate to our cluster
# Our certificate information is stored in the .kube/config
# kubectl reads the credentials and sends the API request on to the API Server
kubectl config view
kubectl config view --raw

# Let's read the certificate information out of our kubeconfig file
# Look for Subject: CN= is the username which is masterclient, it's also in the group
#   (O=) system:masters
kubectl config view --raw -o jsonpath='{ .users[*].user.client-certificate-data }' | base64 --decode > admin.crt
openssl x509 -in admin.crt -text -noout | head -n 15

# We can use -v 6 to see the api request and return code which is 200
kubectl get pods -v 6

# Clean up files no longer needed
rm admin.crt

# 2 - Working with Service Accounts
# Getting Service Accounts information
kubectl get serviceaccounts

# A service account can contain image pull secrets and also mountable secrets, notice
#   the mountable secrets name
kubectl describe serviceaccounts default

# Create a Service Account
kubectl create serviceaccount mysvcaccount1

# This new service account will get its own secret
kubectl describe serviceaccounts mysvcaccount1

# Create a workload, this uses the defined service account myserviceaccount1
kubectl apply -f nginx-deployment.yaml
kubectl get pods

# You can see the Pod spec gets populated with the service account. If we didn't
#   specify one, it would get the default service account for the namespace
# Use serviceAccountName as serviceAccount is deprecated
PODNAEM=$(kubectl get pods -l app=nginx -o jsonpath='{ .items[*].metadata.name }')
kubectl get pod $PODNAME -o yaml

# The secret is mounted in the Pod. See Volumes and Mounts
kubectl describe pod $PODNAME


# 3 - Accessing the API Server inside a Pod
# Let's see how the secret is available inside the Pod
PODNAME=$(kubectl get pods -l app=nginx -o jsonpath='{ .items[*].metadata.name }')
kubectl exec $PODNAME -it -- /bin/bash
ls /var/run/secrets/kubernetes.io/serviceaccount/
cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
cat /var/run/secrets/kubernetes.io/serviceaccount/token

# Load the token and cacert into variables for reuse
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# You're able to authenticate to the API Server with the user... and retrieve some
#   basic and safe information from the API Server
# See this link for more details on API Discovery Roles: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#disovery-roles
curl --cacert $CACERT -X GET https://kubernetes.default.svc/api/
curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET https://kubernetes.default.svc/api/

# But it doesn't have any permissions to access objects... this user is not authorized to
#   access Pods
curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET https://kubernetes.default.svc/api/v1/namespaces/default/pods
exit

# We can also use impersonation to help with our authorization testing
kubectl auth can-i list pods --as=system:serviceaccount:default:mysvcaccount1
kubectl get pods -v 6 --as=system:serviceaccount:default:mysvcaccount1

# Let's leave this deployment running and the service account - we're going to revisit this
#   in our next demo in this module.
