#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

export OPEA_IMAGE_REPO=192.168.0.114:5000
IMAGETAG=latest

if [ -d "GenAIComps" ]; then
            rm -rf GenAIComps
fi
if [ -d "GenAIExamples" ]; then
            rm -rf GenAIExamples
fi

git clone https://github.com/opea-project/GenAIComps.git
cd GenAIComps
docker build -t $OPEA_IMAGE_REPO/opea/embedding-tei:$IMAGETAG -f comps/embeddings/langchain/docker/Dockerfile .
docker push $OPEA_IMAGE_REPO/opea/embedding-tei:$IMAGETAG

docker build -t $OPEA_IMAGE_REPO/opea/retriever-redis:$IMAGETAG -f comps/retrievers/langchain/docker/Dockerfile .
docker push $OPEA_IMAGE_REPO/opea/retriever-redis:$IMAGETAG

docker build -t $OPEA_IMAGE_REPO/opea/reranking-tei:$IMAGETAG -f comps/reranks/langchain/docker/Dockerfile .
docker push $OPEA_IMAGE_REPO/opea/reranking-tei:$IMAGETAG

docker build -t $OPEA_IMAGE_REPO/opea/llm-tgi:$IMAGETAG -f comps/llms/text-generation/tgi/Dockerfile .
docker push $OPEA_IMAGE_REPO/opea/llm-tgi:$IMAGETAG

docker build -t $OPEA_IMAGE_REPO/opea/dataprep-redis:$IMAGETAG -f comps/dataprep/redis/docker/Dockerfile .
docker push $OPEA_IMAGE_REPO/opea/dataprep-redis:$IMAGETAG
cd ..

git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples/ChatQnA/docker
docker build -t $OPEA_IMAGE_REPO/opea/chatqna:$IMAGETAG -f Dockerfile .
docker push $OPEA_IMAGE_REPO/opea/chatqna:$IMAGETAG
cd ../../CodeGen/docker
docker build -t $OPEA_IMAGE_REPO/opea/codegen:$IMAGETAG -f Dockerfile .
docker push $OPEA_IMAGE_REPO/opea/codegen:$IMAGETAG
