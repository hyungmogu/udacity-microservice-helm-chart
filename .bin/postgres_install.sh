#!/bin/bash
helm repo add bitnami https://charts.bitnami.com/bitnami &&\
helm install --set primary.persistence.enabled=false postgres bitnami/postgresql