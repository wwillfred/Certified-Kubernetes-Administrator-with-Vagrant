# Installing and configuring Kubernetes with Vagrant

*This repo is a work in progress*

## Issues
- [ ] Add code for configuring internal ip addresses for each node
- [ ] Research bridged networking as potential simpler solution
- [ ] Debug why unable to attach a shell to a running container (m04-02*.sh)

## Overview
This repository provides step-by-step instructions for installing a Kubernetes cluster on Vagrant virtual machines running Ubuntu 18.04. Most of the steps come from the Pluralsight course [Kubernetes Installation and Configuration Fundamentals](https://www.pluralsight.com/courses/kubernetes-installation-configuration-fundamentals); however, in this repo I've modified the instructions to use Vagrant instead of VMware.

For a repo that automates the installation and configuration of a similar Kubernetes cluster with Vagrant, check out [this repo](https://github.com/techiescamp/vagrant-kubeadm-kubernetes).

These instructions assume you have already installed Vagrant on your system.

## i. IP address ranges
You will need to specify the VM address ranges by copying the [networks.conf](vagrant/networks.conf) file:
```
sudo cp networks.conf /etc/vbox/networks.conf
```

## ii. Specify disk size, if desired
If you want to specify disk size of the virtual machines: Before calling `vagrant up`, you will need to install the vagrant plugin 'vagrant-disksize' for managing disk size (the course suggests 100GB for each VM, but I'm not sure if that much space is strictly necessary):
```
vagrant plugin install vagrant-disksize
```
Then you will need to uncomment out the lines in the [Vagrantfile](vagrant/Vagrantfile) relevant to disk size, including running the [disk-extend.sh](vagrant/disk-extend.sh) script.

## iii. Make the first vagrant up call

```
cd vagrant
vagrant up
```

## iv. Check that each VM is correctly provisioned

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

## v. Getting started
Step through [m03-01_installing_and_configuring_containerd.sh](exercise-modules/m03-01_installing_and_configuring_containerd.sh) to begin. 

[1]: https://unix.stackexchange.com/questions/23072/how-can-i-check-if-swap-is-active-from-the-command-line
