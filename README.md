# WaveMaker ci-cd utils

## k8s-manifestfiles

k8s-manifestfiles have reqired files for deploying a stateless application to kubernetes.

- database_statefulset.yml is deploy default mysql database container for application  
- wm_app_config_and_secret.yml have required configuration and secret like passwords deatils for application and database
- wm_app_loadbalancer.yml will create the loadbalancer service for exposing the application to outside of cluster
- wm_app_webapp.yml will deploy the container image of application in kubernetes pods


## Dockerfile.build
Multi Stage Docker file for sample build tomcat image with war file from sourccode
The Dockerfile will do build using maven , java and node prerequisites at one stage and deploy the application to tomcat in another stage

## azure-pipelines.yml

azure-pipelines.yml file is used to automate the ci-cd process using Azure resources.The will trigger azure pipeline for deploy application to AZURE KUBERNETES SERVICE

## buildspec.yml

buildspec.yml file native AWS automation file. we use this file in AWS codebuild to build application by installing prerequsiites and deploy to AWS EKS service.

## Dockerfile

The Dockerfile is used to create webapp image with tomcat and war file inside it.

## wm_app_ci_cd.sh

The wm_app_ci_cd.sh script will help to deploy the application to EKS.
