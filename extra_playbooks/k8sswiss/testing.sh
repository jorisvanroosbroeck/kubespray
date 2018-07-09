#!/bin/bash

# Install Python requirements
#sudo apt-get install python python-pip -y

# Install Kubespray requirements
#pip install -r "$HOME/kubespray/requirements.txt"

# SSH fingerprints
ssh-keyscan -H 172.16.1.10 >> .ssh/known_hosts
ssh-keyscan -H 172.16.1.11 >> .ssh/known_hosts
ssh-keyscan -H 172.16.1.20 >> .ssh/known_hosts
ssh-keyscan -H 172.16.1.21 >> .ssh/known_hosts
ssh-keyscan -H 172.16.1.22 >> .ssh/known_hosts
ssh-keyscan -H 172.16.1.30 >> .ssh/known_hosts
ssh-keyscan -H c57b-cm-0 >> .ssh/known_hosts
ssh-keyscan -H c57b-master-0 >> .ssh/known_hosts
ssh-keyscan -H c57b-master-1 >> .ssh/known_hosts
ssh-keyscan -H c57b-worker-0 >> .ssh/known_hosts
ssh-keyscan -H c57b-worker-1 >> .ssh/known_hosts
ssh-keyscan -H c57b-worker-2 >> .ssh/known_hosts

# Bootstrap OS'en
#ansible-playbook --ask-become-pass -b -i "$HOME/kubespray/inventory/k8sswiss/hosts.ini" "$HOME/kubespray/extra_playbooks/k8sswiss/bootstrap-k8s-bastion-remote.yml" -v
ansible-playbook -b -i "$HOME/kubespray/inventory/k8sswiss/hosts.ini" "$HOME/kubespray/extra_playbooks/k8sswiss/bootstrap-k8s-bastion-local.yml" -v
ansible-playbook --ask-become-pass -b -i "$HOME/kubespray/inventory/k8sswiss/hosts.ini" "$HOME/kubespray/extra_playbooks/k8sswiss/bootstrap-k8s-cluster.yml" -v

# Install Kubespray
echo "ansible-playbook --ask-become-pass -b -i '$HOME/kubespray/inventory/k8sswiss/hosts.ini' '$HOME/kubespray/cluster.yml'"