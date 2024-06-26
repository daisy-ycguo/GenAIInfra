#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

export OPEA_IMAGE_REPO=100.83.111.251:5000

function build_compos() {
  if [ -d "GenAIComps" ]; then
              rm -rf GenAIComps
  fi
  git clone https://github.com/opea-project/GenAIComps.git
  cd GenAIComps
  #chatqna
  docker build -t $OPEA_IMAGE_REPO/opea/embedding-tei:latest -f comps/embeddings/langchain/docker/Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/embedding-tei:latest

  docker build -t $OPEA_IMAGE_REPO/opea/retriever-redis:latest -f comps/retrievers/langchain/redis/docker/Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/retriever-redis:latest

  docker build -t $OPEA_IMAGE_REPO/opea/reranking-tei:latest -f comps/reranks/langchain/docker/Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/reranking-tei:latest

  docker build -t $OPEA_IMAGE_REPO/opea/llm-tgi:latest -f comps/llms/text-generation/tgi/Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/llm-tgi:latest

  docker build -t $OPEA_IMAGE_REPO/opea/dataprep-redis:latest -f comps/dataprep/redis/langchain/docker/Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/dataprep-redis:latest

  docker build -t $OPEA_IMAGE_REPO/opea/llm-docsum-tgi:latest -f comps/llms/summarization/tgi/Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/llm-docsum-tgi:latest

  cd ..
}

function build_external() {
  git clone https://github.com/huggingface/tei-gaudi
  cd tei-gaudi/
  docker build --no-cache -f Dockerfile-hpu -t $OPEA_IMAGE_REPO/opea/tei-gaudi:latest .
  docker push $OPEA_IMAGE_REPO/opea/tei-gaudi:latest
  cd ..
}


function build_mega() {
  if [ -d "GenAIExamples" ]; then
              rm -rf GenAIExamples
  fi
  git clone https://github.com/opea-project/GenAIExamples.git
  cd GenAIExamples/ChatQnA/docker
  docker build --no-cache -t $OPEA_IMAGE_REPO/opea/chatqna:latest -f Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/chatqna:latest
  cd ../../CodeGen/docker
  docker build --no-cache -t $OPEA_IMAGE_REPO/opea/codegen:latest -f Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/codegen:latest
  cd ../../CodeTrans/docker
  docker build --no-cache -t $OPEA_IMAGE_REPO/opea/codetrans:latest -f Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/codetrans:latest
  cd ../../DocSum/docker
  docker build --no-cache -t $OPEA_IMAGE_REPO/opea/docsum:latest -f Dockerfile .
  docker push $OPEA_IMAGE_REPO/opea/docsum:latest
  cd ../../
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
   *)
     echo "Unkown method"
     ;;
esac
