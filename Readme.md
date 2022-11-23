# Completing Pluralsight: "Kubernetes Installation and Configuration Fundamentals" with Vagrant

The instructor for this course is somewhat agnostic on how the student implements the prescribed configurations, so I created this repository as an example implementation using Vagrant and VirtualBox.

I assume you have already installed Vagrant on your system.

You will need to specify the VM address ranges using the `networks.conf` file in this repository:
```
sudo cp networks.conf /etc/vbox/networks.conf
```

Install vagrant plugin for managing disk size, if desired
```
vagrant plugin install vagrant-disksize
```

Provisioning for the VM's is found in the [Vagrantfile][Vagrantfile]

Step through the [m03.sh][module_3] file to begin. 

[vagrantfile]:Vagrantfile
[module_3]:m03.sh
