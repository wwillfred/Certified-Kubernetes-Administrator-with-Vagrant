# Completing Pluralsight: "Kubernetes Installation and Configuration Fundamentals" with Vagrant

The instructor for this course is somewhat agnostic on how the student implements the prescribed configurations, so I created this repository as an example implementation using Vagrant and VirtualBox.

I assume you have already installed Vagrant on your system.

## IP address ranges
You will need to specify the VM address ranges using the `networks.conf` file in this repository:
```
sudo cp networks.conf /etc/vbox/networks.conf
```

## Specify disk size
Install vagrant plugin for managing disk size, if desired (the course suggests 100GB for each VM):
```
vagrant plugin install vagrant-disksize
```
The [disk-extend script](vagrant/disk-extend.sh) is called by the `Vagrantfile` to resize the filesystems in each VM.

## Vagrantfile
Provisioning for the VM's is found in the [Vagrantfile](vagrant/Vagrantfile)
```
cd vagrant
vagrant up
```
Check that swap is disabled (e.g. in node c1-cp1):
```
vagrant ssh c1-cp1
vi /etc/fstab
```
Check that available disk size is ~100GB (e.g. in node c1-cp1):
```
vagrant ssh c1-cp1
df -h /
```

## Getting started
Step through the [m03.sh][module_3] file to begin. 

[vagrantfile]:Vagrantfile
[module_3]:m03.sh
