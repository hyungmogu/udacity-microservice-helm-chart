REPO_NAME=udacity-kubernetes-cluster-demo/server
EKS_CLUSTER_NAME=udacity-kubernetes-cluster-demo-arm-2
EKS_NODEGROUP_NAME=udacity-eks-node

aws_configure:
	aws configure
eks_create:
	eksctl create cluster \
            --name ${EKS_CLUSTER_NAME} \
            --region us-east-1 \
            --nodegroup-name ${EKS_NODEGROUP_NAME} \
            --node-type t4g.small \
            --nodes 2 \
            --nodes-min 1 \
            --nodes-max 2
eks_delete:
	eksctl delete cluster --name ${EKS_CLUSTER_NAME}
kubernetes_initialize:
	aws eks --region us-east-1 update-kubeconfig --name ${EKS_CLUSTER_NAME}
ecr_create:
	sh ./.bin/ecr_create.sh $(REPO_NAME)
ecr_login:
	ECR_REGISTRY_ID=$$(aws ecr describe-repositories --repository-names "${REPO_NAME}" | jq -r ".repositories[0].registryId") &&\
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$$ECR_REGISTRY_ID.dkr.ecr.us-east-1.amazonaws.com"
ecr_deploy: ecr_login
	ECR_REGISTRY_ID=$$(aws ecr describe-repositories --repository-names "${REPO_NAME}" | jq -r ".repositories[0].registryId") &&\
	docker build -t ${REPO_NAME} analytics/. &&\
	docker tag ${REPO_NAME}:latest $$ECR_REGISTRY_ID.dkr.ecr.us-east-1.amazonaws.com/${REPO_NAME}:latest &&\
	docker push "$$ECR_REGISTRY_ID.dkr.ecr.us-east-1.amazonaws.com/${REPO_NAME}:latest"
postgres_install:
	helm repo add bitnami https://charts.bitnami.com/bitnami &&\
	helm install --set primary.persistence.enabled=false postgres bitnami/postgresql
seed:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d) &&\
	kubectl port-forward --namespace default svc/postgres-postgresql 5432:5432 & \
    (PGPASSWORD="$$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/1_create_tables.sql && \
	PGPASSWORD="$$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/2_seed_users.sql && \
	PGPASSWORD="$$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/3_seed_tokens.sql )
kubernetes_prepare:
	python3 -m venv ./venv &&\
	./venv/bin/pip install -r requirements.txt &&\
	POSTGRES_PASSWORD=$$(kubectl get secret --namespace default postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d) &&\
	POSTGRES_PASSWORD="$$POSTGRES_PASSWORD" ./venv/bin/python3 kubernetes_prepare.py
ingress_controller_install:
	helm upgrade --install ingress-nginx ingress-nginx \
	--repo https://kubernetes.github.io/ingress-nginx \
	--namespace ingress-nginx --create-namespace
start: eks_create kubernetes_initialize ecr_create ecr_deploy postgres_install seed kubernetes_prepare ingress_controller_install
	POSTGRES_PASSWORD=$$(kubectl get secret --namespace default postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d) &&\
	POSTGRES_PASSWORD="$$POSTGRES_PASSWORD" kubectl apply -f ./.kubernetes/