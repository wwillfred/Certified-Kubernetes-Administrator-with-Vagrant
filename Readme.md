# Preparation for the Certified Kubneretes Administrator exam with Vagrant

## Overview
This repository contains step-by-step instructions for completing the exercises in the Pluralsight path [Certified Kubernetes Administrator (CKA)](https://app.pluralsight.com/paths/certificate/certified-kubernetes-administrator). A unique feature of this repository is that it includes code for implementing the courses' exercises with Vagrant virtual machines. 

For a repository that automates the installation and configuration of a similar Kubernetes cluster with Vagrant, check out [this repo](https://github.com/techiescamp/vagrant-kubeadm-kubernetes).

### Attaching shells to Containers
* Several courses in this Pluralsight path require you to attach a shell to an instance of the `gcr.io/google-samples/hello-app:1.0` container, which is not possible with the current version of this container. I've posted a [question on Ask Ubuntu](https://askubuntu.com/questions/1448795/why-can-i-not-attach-a-shell-to-googles-hello-appv1-container) on this problem and have reached out to the instructor on this course to suggest an alternative container.

In the meantime, I have changed a few of the relevant Deployment definitions to instead use the `nginx` container, which allows you to attach a shell.

## Progress by course
- [x] Kubernetes Installation and Configuration Fundamentals
- [X] Managing the Kubernetes API Server and Pods
- [X] Managing Kubernetes Controllers and Deployments
- [X] Configuring and Managing Kubernetes Storage and Scheduling
- [ ] Configuring and Managing Kubernetes Networking, Services, and Ingress
- [ ] Maintaining, Monitoring and Troubleshooting Kubernetes
- [ ] Configuring and Managing Kubernetes Security

## Configuring the virtual machines
Prereq: You will need to have installed Vagrant on your machine.

### i. IP address ranges
You will need to specify the VM address ranges by copying the [networks.conf](vagrant/networks.conf) file:
```
sudo cp networks.conf /etc/vbox/networks.conf
```

### ii. Specify disk size, if desired
If you want to specify disk size of the virtual machines: Before calling `vagrant up`, you will need to install the vagrant plugin 'vagrant-disksize' for managing disk size (the course suggests 100GB for each VM, but I'm not sure if that much space is strictly necessary):
```
vagrant plugin install vagrant-disksize
```
Then you will need to uncomment out the lines in the [Vagrantfile](vagrant/Vagrantfile) relevant to disk size, including running the [disk-extend.sh](vagrant/disk-extend.sh) script.

### iii. Make the first vagrant up call

```
cd vagrant
vagrant up
```

### iv. Check that each VM is correctly provisioned

Check that swap is disabled in each VM (e.g. in node c1-cp1)([source][1]):
```
vagrant ssh c1-cp1
sudo swapon --show
# if this command has no output, then swap is disabled
```
(If you specified disk size:) Check that available disk size is what you had intended (e.g. in node c1-cp1):
```
vagrant ssh c1-cp1
df -h /
```

### v. Getting started
Step through [m03-01_installing_and_configuring_containerd.sh](exercise-modules/Kubernetes_Installation_and_Configuration_Fundamentals/m03-01_installing_and_configuring_containerd.sh) to begin. 

[1]: https://unix.stackexchange.com/questions/23072/how-can-i-check-if-swap-is-active-from-the-command-line
