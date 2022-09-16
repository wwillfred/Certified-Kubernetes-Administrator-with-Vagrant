# install vagrant plugin for managing disk size, if desired
# vagrant plugin install vagrant-disksize

cd ~/Documents/Pluralsight/"Kubernetes Installation and Configuration Fundamentals"/my_files/

vagrant up

vagrant ssh c1-cp1

# check that swap is disabled
vi /etc/fstab

