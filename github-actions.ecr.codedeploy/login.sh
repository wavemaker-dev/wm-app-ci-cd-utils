#!/bin/bash

#to get login into the aws Elastic Container Registry

#This will give us the aws account name.

account_id=$(aws sts get-caller-identity | jq -r .Account)

#This will gives us the region name

region_name=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')

#login into the ECR

aws ecr get-login-password --region $region_name | docker login --username AWS --password-stdin $account_id.dkr.ecr.$region_name.amazonaws.com


