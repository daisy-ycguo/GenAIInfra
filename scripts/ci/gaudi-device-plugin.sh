#!/bin/sh
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

# Set up Gaudi device plugin in a fresh Kubernetes

# use `hl-smi` to check if the Gaudi device can be listed
# which can verify the Gaudi software stack is installed correctly

# Install the Habana container runtime
curl -X GET https://vault.habana.ai/artifactory/api/gpg/key/public | sudo apt-key add --
echo "deb https://vault.habana.ai/artifactory/debian jimmy main" | sudo tee /etc/apt/sources.list.d/artifactory.list
sudo dpkg --configure -a
sudo apt-get update
sudo apt install -y habanalabs-container-runtime
# check habana-container-runtime is installed
ls /usr/bin/habana-container-runtime
#Important! uncomment the following lines in /etc/habana-container-runtime/config.toml
#visible_devices_all_as_default = false
#mount_accelerators = false
# Guess : comment mount_accelerators = false to make sure docker can use Habana

# Edit the containerd configuration file to use the Habana runtime
# sudo tee /etc/containerd/config.toml <<EOF
# disabled_plugins = []
# version = 2
# [plugins]
#   [plugins."io.containerd.grpc.v1.cri"]
#     [plugins."io.containerd.grpc.v1.cri".containerd]
#       default_runtime_name = "habana"
#       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
#         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.habana]
#           runtime_type = "io.containerd.runc.v2"
#           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.habana.options]
#             BinaryName = "/usr/bin/habana-container-runtime"
#   [plugins."io.containerd.runtime.v1.linux"]
#     runtime = "habana-container-runtime"
# EOF

sudo systemctl restart containerd
sudo systemctl restart kubelet

# Install the Gaudi device plugin
kubectl create -f https://vault.habana.ai/artifactory/docker-k8s-device-plugin/habana-k8s-device-plugin.yaml
# Verify that the plugin is running
kubectl get pods -n habana-system

# Create a job that uses the Gaudi device plugin
# $ cat <<EOF | kubectl apply -f -
# apiVersion: batch/v1
# kind: Job
# metadata:
#    name: habanalabs-gaudi-demo
# spec:
#    template:
#       spec:
#          hostIPC: true
#          restartPolicy: OnFailure
#          containers:
#          - name: habana-ai-base-container
#             image: vault.habana.ai/gaudi-docker/1.16.0/ubuntu22.04/habanalabs/pytorch-installer-2.2.2:latest
#             workingDir: /root
#             command: ["hl-smi"]
#             securityContext:
#                capabilities:
#                   add: ["SYS_NICE"]
#             resources:
#                limits:
#                   habana.ai/gaudi: 1
#                   memory: 409Gi
#                   hugepages-2Mi: 95000Mi
# EOF

# Check the logs
# kubectl logs -f habanalabs-gaudi-demo-xxxxx