#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

export OPEA_IMAGE_REPO=100.83.111.251:5000

function docker_build() {
  name=$1
  dockerfile=$2
  docker build -t $OPEA_IMAGE_REPO/opea/$1:latest -f $2 .
  docker push $OPEA_IMAGE_REPO/$1:latest
  docker rmi $OPEA_IMAGE_REPO/$1:latest
}
function build_compos() {
  if [ -d "GenAIComps" ]; then
              rm -rf GenAIComps
  fi
  git clone https://github.com/opea-project/GenAIComps.git
  cd GenAIComps
  #chatqna
  docker_build embedding-tei comps/embeddings/langchain/docker/Dockerfile
  #docker build -t $OPEA_IMAGE_REPO/opea/embedding-tei:latest -f comps/embeddings/langchain/docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/embedding-tei:latest

  docker_build retriever-redis comps/retrievers/langchain/redis/docker/Dockerfile
  #docker build -t $OPEA_IMAGE_REPO/opea/retriever-redis:latest -f comps/retrievers/langchain/redis/docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/retriever-redis:latest

  docker_build reranking-tei comps/reranks/langchain/docker/Dockerfile
  #docker build -t $OPEA_IMAGE_REPO/opea/reranking-tei:latest -f comps/reranks/langchain/docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/reranking-tei:latest

  docker_build llm-tgi comps/llms/text-generation/tgi/Dockerfile
  #docker build -t $OPEA_IMAGE_REPO/opea/llm-tgi:latest -f comps/llms/text-generation/tgi/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/llm-tgi:latest

  docker_build dataprep-redis comps/dataprep/redis/langchain/docker/Dockerfile
  #docker build -t $OPEA_IMAGE_REPO/opea/dataprep-redis:latest -f comps/dataprep/redis/langchain/docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/dataprep-redis:latest
  
  docker_build llm-docsum-tgi comps/llms/summarization/tgi/Dockerfile
  #docker build -t $OPEA_IMAGE_REPO/opea/llm-docsum-tgi:latest -f comps/llms/summarization/tgi/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/llm-docsum-tgi:latest

  cd ..
}

function build_external() {
  git clone https://github.com/huggingface/tei-gaudi
  cd tei-gaudi/
  docker_build tei-gaudi Dockerfile-hpu
  #docker build --no-cache -f Dockerfile-hpu -t $OPEA_IMAGE_REPO/opea/tei-gaudi:latest .
  #docker push $OPEA_IMAGE_REPO/opea/tei-gaudi:latest
  cd ..
}

# function build_gmc() {
#   if [ -d "GenAIInfra" ]; then
#               rm -rf GenAIInfra
#   fi
#   git clone https://github.com/opea-project/GenAIInfra.git
#   cd GenAIInfra/microservices-connector
#   DOCKER_REGISTRY=$OPEA_IMAGE_REPO/opea make build
#   DOCKER_REGISTRY=$OPEA_IMAGE_REPO/opea make push
#   cd ..
# }

function build_mega() {
  if [ -d "GenAIExamples" ]; then
              rm -rf GenAIExamples
  fi
  git clone https://github.com/opea-project/GenAIExamples.git
  cd GenAIExamples/ChatQnA/docker
  docker_build chatqna Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/chatqna:latest -f Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/chatqna:latest
  #docker rmi $OPEA_IMAGE_REPO/opea/chatqna:latest
  cd ui
  docker_build chatqna-ui docker/Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/chatqna-ui:latest -f docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/chatqna-ui:latest
  cd ../../../CodeGen/docker
  docker_build codegen Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/codegen:latest -f Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/codegen:latest
  cd ui
  docker_build codegen-ui docker/Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/codegen-ui:latest -f docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/codegen-ui:latest
  cd ../../../CodeTrans/docker
  docker_build codetrans Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/codetrans:latest -f Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/codetrans:latest
  cd ui
  docker_build codetrans-ui docker/Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/codetrans-ui:latest -f docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/codetrans-ui:latest
  cd ../../../DocSum/docker
  docker_build docsum Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/docsum:latest -f Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/docsum:latest
  cd ui
  docker_build docsum-ui docker/Dockerfile
  #docker build --no-cache -t $OPEA_IMAGE_REPO/opea/docsum-ui:latest -f docker/Dockerfile .
  #docker push $OPEA_IMAGE_REPO/opea/docsum-ui:latest
  cd ../../../
}

if [ $# -eq 0 ]; then
        build_compos
        build_mega
        exit 0
fi

case "$1" in
   comps)
     build_compos
     ;;
   mega)
     build_mega
     ;;
   external)
     build_external
     ;;
  #  gmc)
  #    build_gmc
  #    ;;
   *)
     echo "Unkown method"
     ;;
esac
