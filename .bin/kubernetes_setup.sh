#!/bin/bash
kubectl apply -f ./deployment/base_src/ &&\

# Wait until all pods are deployed
kubectl rollout status --watch --timeout=600s deployment