#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

export OPEA_IMAGE_REPO=192.168.0.114:5000
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
sudo apt-get install -y docker.io
# Install docker compose
sudo apt-get install docker-compose-plugin

# start docker registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2
# config unsecure docker registry
echo "{\"insecure-registries\": [\"$OPEA_IMAGE_REPO\"]}" | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
