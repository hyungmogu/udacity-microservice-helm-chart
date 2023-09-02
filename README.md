# udacity-microservice-helm-chart

This project is done to better understand how kubernetes application manager `helm chart` works, and learn how to use it for [udacity-cloud-devops-project-5](https://github.com/hyungmogu/udacity-cloud-devops-project-5) github repository . There are a lot of parts like provisioning redis or postgresql where I feel more learning is required. I have implemented my solutions but I have questions if there are easier, or simpler approach. I hope that by the end of this project, I learn how to use helm and related tools that the work of provisioning my kubernetes cluster becomes easier.

## Getting Started

### Dependencies
#### Local Environment
1. Python Environment - run Python 3.8+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster
5. `AWS CLI` - For uploading image to Amazon ECR and provisoning Amazon Kubernetes Cluster using EKSCTL
6. `psql` - For seeding and uploading data to Kubernetes PostgreSQL database.

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

### Setup
#### 1. Provisioning EKS Cluster

1. Setup AWS Credentials. The access keys can be gained by following the steps [here](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)

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

3. Make sure IAM Node Group role with the name of `udacity-eks-node` is created following instructions [here](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html#create-worker-node-role)

4. Type below to make the magic work.

```
make start
```

5. If `make start` gets stuck at `Waiting for Kubectl 5432 to become available...`, then please open up a new terminal (IMPORTANT: without closing the current terminal), and type in the following command

```
kubectl port-forward --namespace default svc/postgres-postgresql 5432:5432
```

This can be closed once the migration is complete.

**NOTE:** Always remove amazon parts when done. Otherwise, cost is going to build up. The command I use to remove the EKS cluster is

```
make eks_delete
```

## How Deployment Process Works (Solution to Project Instructions #7)

The deployment process for this project involve Amazon Codebuild, git commandline tool, github, docker and Amazon ECR. Once files are pushed to github, AWS codebuild starts building. Contents in `./analytics` folder are packaged into a docker image, and then it is pushed to AWS ECR via Docker CLI. It's a complex process that involve lots of mechanics.

To get started, please create AWS Codebuild project with the name of `udacity-kubernetes-cluster-demo` [here] (https://us-east-1.console.aws.amazon.com/codesuite/codebuild/projects?region=us-east-1). The settings I've used for my Codebuild project is:

<img src="https://github.com/hyungmogu/udacity-cloud-devops-project-5/assets/6856382/a5def686-c0de-476d-86a2-cf8d55762afb"/>

Once this is done, a build will trigger when a commit is made to github repository.

The values of the environemnt variables in `buildspec.yaml` need to be updated for AWS Codebuild to work. This is because the AWS EKS cluster information is going to be different from what I have. The values of the environment variables is going to be available after following the step `1. Provisioning EKS Cluster`. Once the Kubernetes cluster is generated, the values of the environment vairables can be found [here](https://us-east-1.console.aws.amazon.com/ecr/repositories?region=us-east-1).

<img src="https://github.com/hyungmogu/udacity-cloud-devops-project-5/assets/6856382/2be076fb-75c4-460b-90ab-c7803428e7c9">

One thing to note. Codebuild requires the attachment of `AmazonEC2ContainerRegistryFullAccess` policy to it's IAM role. This is required for docker login and successful deployment of Docker image to Amazon ECR. The reason is Amazon Codebuild abides by the Principle of Least Privilege. The Principle of Least Privilege means a user is given no more privilege than necessary to perform his/her job function. In sum, this policy is needed to grant permission to pull ECR login data, and have ECR accept the incoming Docker image. It's a small work to endure to make this cool feature to work.

In order to attach `AmazonEC2ContainerRegistryFullAccess`policy, please look for self generated IAM role with the name of `codebuild-<codebuild_name>-service-role` [here](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/roles).

<img src="https://github.com/hyungmogu/udacity-cloud-devops-project-5/assets/6856382/30044ee1-c58d-4224-9364-4040d590c290"/>

<img src="https://github.com/hyungmogu/udacity-cloud-devops-project-5/assets/6856382/6ae7cd17-57a9-404d-a7c0-a1b07dae92d7"/>

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
10. Ohmen. Pod don't run, insufficient resources. Stack Overflow. https://stackoverflow.com/questions/53192999/pod-dont-run-insufficient-resources#answer-53195147
11. Kubernetes Team. Reserve Compute Resources for System Daemons. Kubernetes. https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
12. quoc9x. Kubernetes cannot be handled as a Secret illegal base64 data when using environment variable. Stack Overflow. https://stackoverflow.com/questions/73680884/kubernetes-cannot-be-handled-as-a-secret-illegal-base64-data-when-using-environm#answer-73681375
13. davidism. Flask-SQLAlchemy db.create_all() raises RuntimeError working outside of application context. Stack Overflow. https://stackoverflow.com/questions/73961938/flask-sqlalchemy-db-create-all-raises-runtimeerror-working-outside-of-applicat#answer-73962250
14. Ingress Nginx Controller Team. Rewrite. Ingress Nginx Controller. https://kubernetes.github.io/ingress-nginx/examples/rewrite/
15. not Michal. How to handle secrets in AWS Codebuild. Medium. https://mpasierbski.medium.com/how-to-handle-secrets-in-aws-codebuild-6e1b96013712
16. Jimmy. AWS CodeBuild GetAuthorizationToken failed. Stack Overflow. https://stackoverflow.com/questions/43033559/aws-codebuild-getauthorizationtoken-failed#answer-52264228
17. Peter V.Merch. Kubectl port forward reliably in a shell script. Stack Overflow.https://stackoverflow.com/questions/67415637/kubectl-port-forward-reliably-in-a-shell-script
18. Shane Bishop, FDS. How to check if a process id (PID) exists. Stack Overflow.