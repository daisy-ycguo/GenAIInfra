#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

REGISTRY_URL="localhost:5000"

function list_images() {
    output=$(curl -s -X GET http://${REGISTRY_URL}/v2/_catalog)
    repositories=$(echo "$output" | jq -r '.repositories[]')
    for repo in $repositories; do
        tagoutput=$(curl -s -X GET http://${REGISTRY_URL}/v2/${repo}/tags/list)
        tags=$(echo "$tagoutput" | jq -r '.tags[]?')
        if [ "$tags" != "" ]; then
            for tag in $tags; do
                echo "${repo}:${tag}"
            done
        else
            echo "${repo}:<null>"
        fi
    done
}

function list_names() {
    output=$(curl -s -X GET http://${REGISTRY_URL}/v2/_catalog)
    repositories=$(echo "$output" | jq -r '.repositories[]')
    echo $repositories
}

function list_tags() {
    echo "Listing tags for image $1:"
    image=$1
    output=$(curl -X GET http://${REGISTRY_URL}/v2/${image}/tags/list)
}

function delete_tags() {
    echo "Deleting tag $2 for image $1:"
    image=$1
    tag=$2
    diagest=$( curl -s -I -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' http://${REGISTRY_URL}/v2/${image}/manifests/${tag} | grep Docker-Content-Digest | awk '{print $2}' | tr -d '\r')
    echo "$diagest"
    curl -X DELETE http://${REGISTRY_URL}/v2/${image}/manifests/${diagest}
}

function usage_print() {
    echo "Usage: $0 images|tags|delete"
    echo "./registry.sh images: List all images in the registry"
    echo "./registry.sh delete <image> <tag>: Delete the tag for the image"
    echo "./registry.sh names: List all names"
    echo "./registry.sh tags <image name>: list all tags"
    echo "./registry.sh help: print usage"
}


if [ $# -eq 0 ]; then
    usage_print
    exit 1
fi

case "$1" in
   "images")
        list_images
        ;;
   "delete")
        delete_tags $2 $3
        ;;
    "help")
        usage_print
        ;;
    "names")
        list_names
        ;;
    "tags")
        list_tags $1
        ;;
    *)
        echo "Invalid option"
        usage_print
        exit 1
        ;;
esac
