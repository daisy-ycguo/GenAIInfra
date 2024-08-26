#!/bin/bash
# Excuted inside KIND docker container
for img in `sudo nerdctl -n k8s.io images --format "{{.Repository}}:{{.Tag}} {{.CreatedAt}}" | grep ':5000' | grep -v latest | awk -v week=$(date -d '1 week ago' '+%Y-%m-%d') '{if ($2 < week) print $1}'`
do
        sudo nerdctl -n k8s.io rmi $img
done

for img in `sudo nerdctl -n k8s.io images --names | grep '^sha256' | awk '{print $1}'`
do
        sudo nerdctl -n k8s.io rmi $img
done

sudo nerdctl -n k8s.io system prune -f
