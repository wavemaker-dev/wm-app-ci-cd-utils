#!/usr/bin/bash

#pull the image and run the container.

#get the region

region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')

#get the Image tag from the ssm parameter store

Image_tag=$(aws ssm get-parameter --name "/github-ci-cd/build_number"  --region "$region" | jq -r .[].Value)

#get the aws account number

Account_num=$(aws sts get-caller-identity | jq -r .Account)

#get the ecr repo name from the aws ssm parameter store

repo_name=$(aws ssm get-parameter --name "/github-ci-cd/repo"  --region "$region" | jq -r .[].Value)

#pull the docker image

docker pull $Account_num.dkr.ecr.$region.amazonaws.com/$repo_name:$Image_tag

#removing the container if already exists with the same name

sudo docker rm -f wm-test

#running the container in 80 port 

sudo docker run  --detach -p 80:8080 --name  wm-test $Account_num.dkr.ecr.$region.amazonaws.com/$repo_name:$Image_tag

#removing unwante docker images 

sudo docker images prune -a 






