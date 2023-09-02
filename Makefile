REPO_NAME=udacity-kubernetes-cluster-demo/server
EKS_CLUSTER_NAME=udacity-kubernetes-cluster-demo-arm-2
EKS_NODEGROUP_NAME=udacity-eks-node

aws_configure:
	aws configure
eks_create:
	sh ./.bin/eks_create.sh ${EKS_CLUSTER_NAME} ${EKS_NODEGROUP_NAME}
eks_delete:
	sh ./.bin/eks_delete.sh ${EKS_CLUSTER_NAME}
kubernetes_initialize:
	sh ./.bin/kubernetes_initialize.sh ${EKS_CLUSTER_NAME}
ecr_create:
	sh ./.bin/ecr_create.sh ${REPO_NAME}
ecr_login:
	sh ./.bin/ecr_login.sh ${REPO_NAME}
ecr_deploy: ecr_login
	sh ./.bin/ecr_deploy.sh ${REPO_NAME}
postgres_install:
	sh ./.bin/postgres_install.sh
seed:
	sh ./.bin/seed.sh
kubernetes_prepare:
	sh ./.bin/kubernetes_prepare.sh
ingress_controller_install:
	sh ./.bin/ingress_controller_install.sh
kubernetes_setup:
	sh ./.bin/kubernetes_setup.sh
kubernetes_get_alb_url:
	sh ./.bin/kubernetes_get_alb_url.sh
start: eks_create kubernetes_initialize ecr_create ecr_deploy postgres_install seed kubernetes_prepare ingress_controller_install kubernetes_setup kubernetes_get_alb_url