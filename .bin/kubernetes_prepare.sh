#!/bin/bash
python3 -m venv ./venv &&\
./venv/bin/pip install -r requirements.txt &&\
POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d) &&\
POSTGRES_PASSWORD="$POSTGRES_PASSWORD" ./venv/bin/python3 kubernetes_prepare.py