#!/bin/bash
ECR_REGISTRY_ID=$(aws ecr describe-repositories --repository-names "$1" | jq -r ".repositories[0].registryId") &&\
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY_ID.dkr.ecr.us-east-1.amazonaws.com"