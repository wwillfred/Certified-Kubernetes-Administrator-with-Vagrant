m04-01 Troubleshooting Nodes Break Stuff

# To use this file to break stuff on your nodes, set the username variable to your
#   username.
# This account will need sudo rights on the nodes to break things.
# You'll need to enter your sudo password for this account on each node for each
#   execution.
# Execute the commands here one line at a time rather than running the whole script at
#   once.

# Worker Node - stopped kubelet
vagrant ssh c1-node1 -c "sudo systemctl stop kubelet.service"
vagrant ssh c1-node1 -c "sudo systemctl disable kubelet.service"

# Worker Node - inaccessible config.yaml
vagrant ssh c1-node2 -c "sudo mv /var/lib/kubelet/config.yaml /var/lib/kubelet/config.yml"
vagrant ssh c1-node2 -c "sudo systemctl restart kubelet.service"

# Worker Node - misconfigured systemd unit
vagrant ssh c1-node3 -c "sudo sed -i ''s/config.yaml/config.yml/'' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
vagrant ssh c1-node3 -c "sudo systemctl daemon-reload"
vagrant ssh c1-node3 -c "sudo systemctl restart kubelet.service"
