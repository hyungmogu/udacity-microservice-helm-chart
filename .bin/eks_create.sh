#!/bin/bash

eksctl create cluster \
        --name $1 \
        --region us-east-1 \
        --nodegroup-name $2 \
        --node-type t4g.small \
        --nodes 2 \
        --nodes-min 1 \
        --nodes-max 2