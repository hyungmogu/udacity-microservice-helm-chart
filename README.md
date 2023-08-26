# udacity-microservice-helm-chart

This project is done to better understand how kubernetes application manager `helm chart` works, and learn how to use it for my kubernetes cluster. Rather than a herculian-effort-required manual installation of prometheus and grafana, help by helm would be invaluable.

## Project Instructions
1. Set up a Postgres database with a Helm Chart.
2. Create a Dockerfile for the Python application.
3. You'll submit the Dockerfile
4. Write a simple build pipeline with AWS CodeBuild to build and push a Docker image into AWS ECR.
5. Take a screenshot of AWS CodeBuild pipeline for your project submission.
6. Take a screenshot of AWS ECR repository for the application's repository.
7. Create a service and deployment using Kubernetes configuration files to deploy the application.
8. You'll submit all the Kubernetes config files used for deployment (ie YAML files).
9. Take a screenshot of running the kubectl get svc command.
10. Take a screenshot of kubectl get pods.
11. Take a screenshot of kubectl describe svc <DATABASE_SERVICE_NAME>.
12. Take a screenshot of kubectl describe deployment <SERVICE_NAME>.
13. Check AWS CloudWatch for application logs.
14. Take a screenshot of AWS CloudWatch logs for the application.
15. Create a README.md file in your solution that serves as documentation for your user to detail how your deployment process works and how the user can deploy changes. The details should not simply rehash what you have done on a step by step basis. Instead, it should help an experienced software developer understand the technologies and tools in the build and deploy process as well as provide them insight into how they would release new builds.
