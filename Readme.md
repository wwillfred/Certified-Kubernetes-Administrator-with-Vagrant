Installing and configuring Kubernetes using Vagrant

This repository serves as step-by-step instructions for installing a Kubernetes cluster on Vagrant virtual machines running Ubuntu 18.04. Most of the steps come from the Pluralsight course [Kubernetes Installing and Configuration Fundamentals](https://www.pluralsight.com/courses/kubernetes-installation-configuration-fundamentals); however, in this repo I've included steps that account for Vagrant's networking quirks.

For a repo that uses similar steps and automates the installation and configuration steps, check out [this repo](https://github.com/techiescamp/vagrant-kubeadm-kubernetes)

These steps assume you have already installed Vagrant on your system.

## IP address ranges
You will need to specify the VM address ranges using the [networks.conf](vagrant/networks.conf) file:
```
sudo cp networks.conf /etc/vbox/networks.conf
```

## Specify disk size
Before calling `vagrant up`, you will need to install a vagrant plugin for managing disk size (the course suggests 100GB for each VM, but I'm not sure if that much space is strictly necessary):
```
vagrant plugin install vagrant-disksize
```
The [disk-extend script](vagrant/disk-extend.sh) resizes the filesystems in each VM the first time `vagrant up` is run.

## Make the first vagrant up call

```
cd vagrant
vagrant up
```

## Check that each VM is correctly provisioned

Check that swap is disabled in each VM (e.g. in node c1-cp1)([source][1]):
```
vagrant ssh c1-cp1
sudo swapon --show
# if this command has no output, then swap is disabled
```
Check that available disk size is ~100GB (e.g. in node c1-cp1):
```
vagrant ssh c1-cp1
df -h /
```

## Getting started
Step through the [m03.sh](m03.sh) file to begin. 

[1]: https://unix.stackexchange.com/questions/23072/how-can-i-check-if-swap-is-active-from-the-command-line
