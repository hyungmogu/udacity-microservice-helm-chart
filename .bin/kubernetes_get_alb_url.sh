#!/bin/bash
HOST=$(kubectl get svc --namespace ingress-nginx -o jsonpath="{.items[0].status.loadBalancer.ingress[0].hostname}")
echo "The host to access the Kubernetes cluster is:"
echo "http://$HOST"