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

# Kind configuration kind_cluster.yaml
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# nodes:
#   - role: control-plane
#     extraMounts:
#       - hostPath: /home/sdp/models
#         containerPath: /mnt/models
# containerdConfigPatches:
# - |-
#   [plugins."io.containerd.grpc.v1.cri".registry.mirrors."100.80.243.74:5000"]
#     endpoint = ["http://100.80.243.74:5000"]
#   [plugins."io.containerd.grpc.v1.cri".registry.configs."100.80.243.74:5000".tls]
#     insecure_skip_verify = true

# start a kind cluster
kind create cluster --name mycluster --config kind_cluster.yaml
kubectl cluster-info --context kind-mycluster
# get clusters
# kind get clusters
# delete cluster
# kind delete cluster --name mycluster