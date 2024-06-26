#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

set -xe

# clean up tag images
lines=$( ./registry.sh images | grep -v latest)
for line in $lines; do
    image=$(echo "$line" | cut -d':' -f1)
    tag=$(echo "$line" | cut -d':' -f2)
    ./registry.sh delete $image $tag
done

sleep 20

# run garbage-collect to clean up disk
docker exec registry bin/registry garbage-collect /etc/docker/registry/config.yml
