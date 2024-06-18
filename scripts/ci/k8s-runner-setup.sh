#!/bin/sh
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

# Set up a K8s runner from fresh Ubuntu 22.04 servers
# This script is used in the CI pipeline to set up a K8s runner
# It installs the necessary tools and dependencies to run the K8s runner

# single node name
# NOTE: make sure you can ssh to the node without password.
NODENAME=node1
userid=$(whoami)
export OPEA_IMAGE_REPO=100.80.243.74:5000

# Install Python3.11
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt install python3.11 python3.10-venv python3-pip
# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Install huggingface-cli
pip install -U "huggingface_hub[cli]"

# git clone kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git
# Install ansible
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements.txt

## One Node Cluster Installation
# reset inventory
# cp -rfp inventory/local inventory/mycluster
# # replace node1 with the actual node name in the inventory
# sed -i "s/node1/$NODENAME/g" inventory/mycluster/hosts.ini
# # reset environment
# ansible-playbook -i inventory/mycluster/hosts.ini  --become --become-user=root reset.yml
# ansible-playbook -i inventory/mycluster/hosts.ini  --become --become-user=root cluster.yml
# # config kubectl
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Multi Node Cluster Installation
## TODO
cp -rfp inventory/sample inventory/mycluster
# replace node1 with the actual node name in the inventory
sed -i "s/node1/$NODENAME/g" inventory/mycluster/inventory.ini
# Note: if you have multiple netcards, you can specify the network interface
# go to inventory/mycluster/group_vars/k8s_cluster/k8s-net-calico.yml and set calico_ip_auto_method
# calico_ip_auto_method: "interface=eth.*"
# reset environment
# Note: make sure ssh <local_ip> works without password, otherwise, you will meet error during reset
ansible-playbook -i inventory/mycluster/inventory.ini  --become --become-user=root reset.yml
ansible-playbook -i inventory/mycluster/inventory.ini  --become --become-user=root cluster.yml
# config kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Config docker repo key
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
# Install docker
# sudo apt-get install -y docker.io
sudo apt-get install -y docker-ce
# Install docker compose
sudo apt-get install docker-compose-plugin

# start docker registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2
# config unsecure docker registry
echo "{\"insecure-registries\": [\"$OPEA_IMAGE_REPO\"]}" | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
# config unsecure image repo in kubernetes
# echo "server = \"http://$OPEA_IMAGE_REPO\"" | sudo tee /etc/containerd/certs.d/$OPEA_IMAGE_REPO/hosts.toml
# echo "[host.\"http://$OPEA_IMAGE_REPO\"]" | sudo tee -a /etc/containerd/certs.d/$OPEA_IMAGE_REPO/hosts.toml
# echo "  capabilities = [\"pull\", \"resolve\", \"push\"]" | sudo tee -a /etc/containerd/certs.d/$OPEA_IMAGE_REPO/hosts.toml
# echo "  skip_verify = true" | sudo tee -a /etc/containerd/certs.d/$OPEA_IMAGE_REPO/hosts.toml
# edit /etc/containerd/config.toml
#    [plugins."io.containerd.grpc.v1.cri".registry]
#      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
#        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
#          endpoint = ["https://registry-1.docker.io"]
#        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."100.80.243.74:5000"]
#          endpoint = ["http://100.80.243.74:5000"]
sudo systemctl restart containerd
# mkdir
mkdir -p /home/$userid/charts-mnt
mkdir -p /home/$userid/logs

## Add node
# edit inventory.ini, replace node2 with real node name
ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root scale.yml -b -v
# mkdirs /home/$userid/charts-mnt /home/$userid/logs
# config unsecure image repo
# config environment in .bashrc :export OPEA_IMAGE_REPO=100.80.243.74:5000