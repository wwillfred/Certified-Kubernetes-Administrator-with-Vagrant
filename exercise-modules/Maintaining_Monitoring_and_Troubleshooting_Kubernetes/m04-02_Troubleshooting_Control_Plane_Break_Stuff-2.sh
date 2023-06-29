m04-02 Troubleshooting Control Plane Break Stuff 2

vagrant ssh c1-cp1

# Break the scheduler Control Plane Pod
sudo cp /etc/kubernetes/manifests/kube-scheduler.yaml ~/kube-scheduler.yaml.ORIG
sudo sed -i 's/image: registry.k8s.io\/kube-scheduler:/image: registry.k8s.io\/kube-cheduler:/' /etc/kubernetes/manifests/kube-scheduler.yaml
