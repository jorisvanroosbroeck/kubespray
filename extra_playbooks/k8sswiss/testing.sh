#!/bin/bash

# Install Python requirements
sudo apt-get install python python-pip -y

# Install Kubespray requirements
pip install -r "$HOME/kubespray/requirements.txt"

# Bootstrap OS'en
ansible-playbook --ask-become-pass -b -i "$HOME/kubespray/inventory/k8sswiss/hosts.ini" "$HOME/kubespray/extra_playbooks/k8sswiss/bootstrap-k8s-bastion-remote.yml"
ansible-playbook --ask-become-pass -b -i "$HOME/kubespray/inventory/k8sswiss/hosts.ini" "$HOME/kubespray/extra_playbooks/k8sswiss/bootstrap-k8s-bastion-local.yml"
ansible-playbook --ask-become-pass -b -i "$HOME/kubespray/inventory/k8sswiss/hosts.ini" "$HOME/kubespray/extra_playbooks/k8sswiss/bootstrap-k8s-cluster.yml"

# Install Kubespray
echo "ansible-playbook --ask-become-pass -b -i '$HOME/kubespray/inventory/k8sswiss/hosts.ini' '$HOME/kubespray/cluster.yml'"