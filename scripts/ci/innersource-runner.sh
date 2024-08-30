#!/bin/sh
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

# set up jq and yq
sudo apt install yq

# set up docker
sudo apt install docker-ce
sudo usermod -aG docker ansible
newgrp docker

# install CA
# from https://github.com/intel-innersource/applications.infrastructure.caas.caas-general/blob/master/scripts/ca_install.sh
# docker login
docker login ccr-registry.caas.intel.com
# WARNING! Your password will be stored unencrypted in /home/ansible/.docker/config.json.
# Configure a credential helper to remove this warning. See
# https://docs.docker.com/engine/reference/commandline/login/#credential-stores

