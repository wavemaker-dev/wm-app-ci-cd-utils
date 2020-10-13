# WaveMaker CI/CD utils

## cluster-auto-scaler

cluser-auto-scaler folder have k8s manifestfiles for create cluster autoscaler in AWS and AZURE cloud Kubernetes services.

- aws-cluster-autoscaler.yml is used to create cluser autoscaler service in AWS kubernetes service.
- azure-cluster-autoscale.yml is used to create cluster autoscaler servive in AZURE kubernetes service

## k8s-manifestfiles

k8s-manifestfiles have required files for deploying a stateless application to kubernetes.

- database_statefulset.yml is deploy default mysql database container for application  
- wm_app_config_and_secret.yml have required configuration and secret like passwords deatils for application and database
- wm_app_alb_ingress_service.yml file used to creating ingree service when ingress controller is ALB.
- wm_app_hpa.yml file used to create horizantal pod autoscaler in cluster
- wm_app_loadbalancer.yml will create the loadbalancer service for exposing the application to outside of cluster
- wm_app_nginx_ingress_service.yml is used to create ingress service when ingress controller is nginx
- wm_app_nginx_ingress_service_logging.yml file used to create ingress service for observability tools when ingress controller is nginx
- wm_app_webapp.yml will deploy the container image of application in kubernetes pods

## loggging

logging folder have configuration and manifestfiles for deploying the observability tools.

- observability-tools-deployment.yml file have a process to deploy observability tools on k8s cluster

### elasticsearch

- elasticsearch folder have a k8s manifest file for deploy the elasticsearch cluster

### fluentd

- fluentd folder have a fluetd configuration files and daemonset manifestfile for deploy fluentd daemonset in cluster

### grafana

- grafana folder have a helm configuration file for deploy the grafan by using helm chart

### kibana

- kibana have a helm configuration file for deploy the kibana by using helm chart

### prometheus

- prometheus have a helm configuration file for deploy the prometheus by using helm chart



## Dockerfile.build

Multi Stage Docker file for sample build tomcat image with war file from sourccode
The Dockerfile will do build using maven , java and node prerequisites at one stage and deploy the application to tomcat in another stage

## azure-pipelines.yml

azure-pipelines.yml file is used to automate the ci-cd process using Azure resources.The will trigger azure pipeline for deploy application to AZURE KUBERNETES SERVICE

## aws-code-build-spec.yml

aws-code-build-spec.yml file native AWS automation file. we use this file in AWS codebuild to build application by installing prerequsiites and deploy to AWS EKS service.

## Dockerfile

The Dockerfile is used to create webapp image with tomcat and war file inside it.

## wm_app_ci_cd.sh

The wm_app_ci_cd.sh script will help to deploy the application to EKS.

## azure-pipeline-deploy-role.yml

azure-pipeline-deploy-role.yml file used to provide permissions to azure pipeline to deploy service and other resources in required namespaces


