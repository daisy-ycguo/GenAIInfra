#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# check kubectl is ready
# $ kubectl version
# Client Version: v1.30.2
# Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
# The connection to the server localhost:8080 was refused - did you specify the right host or port?

# install kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# check kind is ready
# $ kind --version
# kind version 0.23.0

# start a kind cluster
kind create cluster --name mycluster --config config/kind-cluster.yaml
kubectl cluster-info --context kind-mycluster
# get clusters
# kind get clusters
# delete cluster
# kind delete cluster --name mycluster

# In order to prepare K8s env for GMC controller,
# get .cache/huggingface/ ready with a hub folder and a token file including huggingface token.

#########Create KIND in Gaudi server###############
# 
# Ensure habana-runtime is installed
# Ensure docker runtime is configured to support habana-runtime 
# cat /etc/docker/daemon.json
# {
#    "default-runtime": "habana",
#    "runtimes": {
#       "habana": {
#             "path": "/usr/bin/habana-container-runtime",
#             "runtimeArgs": []
#       }
#    }
# }
# habana-runtime `/etc/habana-container-runtime/config.toml` is configured as:
# comment mount_accelerators = false
# uncomment visible_devices_all_as_default = false
# Restart containerd
# sudo systemctl restart containerd
# check docker supports habana
# docker run -t -i --rm --runtime=habana -e HABANA_VISIBLE_DEVICES=all busybox
# ls /dev/ac*

# create KIND cluster
# kind create cluster --name mycluster --config config/kind-cluster-habana.yaml
# kubectl cluster-info --context kind-mycluster
# kubectl create -f https://vault.habana.ai/artifactory/docker-k8s-device-plugin/habana-k8s-device-plugin.yaml
# kubectl get pods -n habana-system
# Test with habana-job:
# kubectl apply -f config/test-habana-job.yaml
# check log
# kubectl logs habanalabs-gaudi-demo-xxxx
# delete cluster
# kind delete cluster --name mycluster
