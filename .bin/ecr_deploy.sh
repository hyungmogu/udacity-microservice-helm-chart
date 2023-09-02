#!/bin/bash
ECR_REGISTRY_ID=$(aws ecr describe-repositories --repository-names "$1" | jq -r ".repositories[0].registryId") &&\
docker build -t $1 analytics/. &&\
docker tag $1:latest $ECR_REGISTRY_ID.dkr.ecr.us-east-1.amazonaws.com/$1:latest &&\
docker push "$ECR_REGISTRY_ID.dkr.ecr.us-east-1.amazonaws.com/$1:latest"