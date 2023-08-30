# udacity-microservice-helm-chart

This project is done to better understand how kubernetes application manager `helm chart` works, and learn how to use it for [udacity-cloud-devops-project-5](https://github.com/hyungmogu/udacity-cloud-devops-project-5) github repository . There are a lot of parts like provisioning redis or postgresql where I feel more learning is required. I have implemented my solutions but I have questions if there are easier, or simpler approach. I hope that by the end of this project, I learn how to use helm and related tools that the work of provisioning my kubernetes cluster becomes easier.

## Description

The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide you functions as expected locally and you are expected to help build a pipeline to deploy it in Kubernetes.

## Getting Started

### Dependencies
#### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster
5. `AWS CLI` - For uploading image to Amazon ECR and provisoning Amazon Kubernetes Cluster using EKSCTL

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

### Setup
#### 1. Provisioning EKS Cluster

1. Setup AWS Credentials

```
aws configure
```

2. Check if you are connected

```
aws sts get-caller-identity
```

If correct, it should give output in the following:

```
{
    "Account": "123456789012",
    "UserId": "AR#####:#####",
    "Arn": "arn:aws:sts::123456789012:assumed-role/role-name/role-session-name"
}
```

3. Make sure IAM Node Group role is generated via instructions [here](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html#create-worker-node-role)

4. Provision Kubernetes Cluster using EKSCTL

```
eksctl create cluster \
            --name udacity-kubernetes-cluster-demo-arm \
            --region us-east-1 \
            --nodegroup-name <NODE_GROUP_ROLE_NAME> \
            --node-type t4g.micro \
            --nodes 2 \
            --nodes-min 1 \
            --nodes-max 2
```

#### 2. Configure a Database
Set up a Postgres database using a Helm Chart.

1. Set up Bitnami Repo
```bash
helm repo add <REPO_NAME> https://charts.bitnami.com/bitnami
```

2. Install PostgreSQL Helm Chart
```
helm install --set primary.persistence.enabled=false <SERVICE_NAME> <REPO_NAME>/postgresql
```

This should set up a Postgre deployment at `<SERVICE_NAME>-postgresql.default.svc.cluster.local` in your Kubernetes cluster. You can verify it by running `kubectl svc`

By default, it will create a username `postgres`. The password can be retrieved with the following command:
```bash
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default <SERVICE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

echo $POSTGRES_PASSWORD
```

<sup><sub>* The instructions are adapted from [Bitnami's PostgreSQL Helm Chart](https://artifacthub.io/packages/helm/bitnami/postgresql).</sub></sup>

3. Test Database Connection
The database is accessible within the cluster. This means that when you will have some issues connecting to it via your local environment. You can either connect to a pod that has access to the cluster _or_ connect remotely via [`Port Forwarding`](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

* Connecting Via Port Forwarding
```bash
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
```

* Connecting Via a Pod
```bash
kubectl exec -it <POD_NAME> bash
PGPASSWORD="$POSTGRES_PASSWORD" psql postgres://postgres@<SERVICE_NAME>:5432/postgres -c <COMMAND_HERE>
```

4. Run Seed Files
We will need to run the seed files in `db/` in order to create the tables and populate them with data.

```bash
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>
```

### 3. Running the Analytics Application Locally
In the `analytics/` directory:

1. Install dependencies
```bash
pip install -r requirements.txt
```
2. Run the application (see below regarding environment variables)
```bash
<ENV_VARS> python app.py
```

There are multiple ways to set environment variables in a command. They can be set per session by running `export KEY=VAL` in the command line or they can be prepended into your command.

* `DB_USERNAME`
* `DB_PASSWORD`
* `DB_HOST` (defaults to `127.0.0.1`)
* `DB_PORT` (defaults to `5432`)
* `DB_NAME` (defaults to `postgres`)

If we set the environment variables by prepending them, it would look like the following:
```bash
DB_USERNAME=username_here DB_PASSWORD=password_here python app.py
```
The benefit here is that it's explicitly set. However, note that the `DB_PASSWORD` value is now recorded in the session's history in plaintext. There are several ways to work around this including setting environment variables in a file and sourcing them in a terminal session.

3. Verifying The Application
* Generate report for check-ins grouped by dates
`curl <BASE_URL>/api/reports/daily_usage`

* Generate report for check-ins grouped by users
`curl <BASE_URL>/api/reports/user_visits`

## Project Instructions
1. Set up a Postgres database with a Helm Chart.
2. Create a Dockerfile for the Python application.
    - a. You'll submit the Dockerfile
3. Write a simple build pipeline with AWS CodeBuild to build and push a Docker image into AWS ECR.
    - a. Take a screenshot of AWS CodeBuild pipeline for your project submission.
    - b. Take a screenshot of AWS ECR repository for the application's repository.
4. Create a service and deployment using Kubernetes configuration files to deploy the application.
5. You'll submit all the Kubernetes config files used for deployment (ie YAML files).
    - a. Take a screenshot of running the kubectl get svc command.
    - b. Take a screenshot of kubectl get pods.
    - c. Take a screenshot of kubectl describe svc <DATABASE_SERVICE_NAME>.
    - d. Take a screenshot of kubectl describe deployment <SERVICE_NAME>.
6. Check AWS CloudWatch for application logs.
    - a. Take a screenshot of AWS CloudWatch logs for the application.
7. Create a README.md file in your solution that serves as documentation for your user to detail how your deployment process works and how the user can deploy changes. The details should not simply rehash what you have done on a step by step basis. Instead, it should help an experienced software developer understand the technologies and tools in the build and deploy process as well as provide them insight into how they would release new builds.


## References

1. Emre Yilmaz. 3 Ways for Environment Variables in AWS CodeBuild Buildspecs. Shikisoft. https://blog.shikisoft.com/define-environment-vars-aws-codebuild-buildspec/
2. Cloud Quick Labs. Kubernetes Application Deployment from AWS ECR to EKS. Youtube. https://www.youtube.com/watch?v=Y4kNINPe9ho
3. Vladislav. Docker ARG, ENV and .env - a Complete Guide. vsupalov. https://vsupalov.com/docker-arg-env-variable-guide/
4. joar. How to install psycopg2 with "pip" on Python?. Stack Overflow. https://stackoverflow.com/questions/5420789/how-to-install-psycopg2-with-pip-on-python#answer-5450183
5. terpez. Daemon error responses: exec format error and Container is restarting, wait until the container is running. Docker Community Forum. https://forums.docker.com/t/daemon-error-responses-exec-format-error-and-container-is-restarting-wait-until-the-container-is-running/110385/2
6. Justin Lee. Demo: Creating an EKS Cluster. Udacity. https://learn.udacity.com/paid-courses/cd12355/lessons/8baf6c23-4fd5-481e-97ef-258d8f1f4556/concepts/64e226da-b22e-4be1-bb10-1bf614e0ef48
7. EKSCTL Team. ARM Support. EKSCTL. https://eksctl.io/usage/arm-support/
8. Viet N, leokury. EBS-CSI can't provision persistent volume for the postgresql pod. Udacity Knowledge. https://knowledge.udacity.com/questions/994218
9. Ajay Kulkarni. How to Install psql on Mac, Ubuntu, Debian, Windows. Timescale. https://www.timescale.com/blog/how-to-install-psql-on-mac-ubuntu-debian-windows/
10. Ohmen. Pod don't run, insufficient resources. Stack Overflow. https://stackoverflow.com/questions/53192999/pod-dont-run-insufficient-resources
11. Kubernetes Team. Reserve Compute Resources for System Daemons. Kubernetes. https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
12. quoc9x. Kubernetes cannot be handled as a Secret illegal base64 data when using environment variable. Stack Overflow. https://stackoverflow.com/questions/73680884/kubernetes-cannot-be-handled-as-a-secret-illegal-base64-data-when-using-environm#answer-73681375