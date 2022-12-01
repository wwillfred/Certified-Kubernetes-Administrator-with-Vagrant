# Completing Pluralsight: "Kubernetes Installation and Configuration Fundamentals" with Vagrant

The instructor for this course is somewhat agnostic on how the student implements the prescribed configurations, so I created this repository as an example implementation using Vagrant and VirtualBox.

This assumes you have already installed Vagrant on your system.

## IP address ranges
You will need to specify the VM address ranges using the `networks.conf` file in this repository:
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

## Check that each VM is correctly configured

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
