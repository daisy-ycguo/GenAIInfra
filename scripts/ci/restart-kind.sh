#!/bin/bash

# crontab -e
# 0 18 * * 6 /home/sdp/workspace/restart-kind.sh >> /home/sdp/workspace/cronlogs/cleanjob_$(date +\%Y\%m\%d).log 2>&1
# Get the current week number
week_number=$(date +%V)

# Check if the week number is even
if (( week_number % 2 == 0 )); then
  # Your command goes here
  echo "Restarting because it's an even-numbered week."
  kind delete cluster --name mycluster
  docker volume prune
  kind create cluster --name mycluster --config /home/sdp/workspace/cluster-config.yaml
  kubectl cluster-info --context kind-mycluster
else
  echo "Skipping this week."
fi
