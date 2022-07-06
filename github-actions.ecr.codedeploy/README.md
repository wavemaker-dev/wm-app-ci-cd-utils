
# CONTINUOUS INTEGRATION AND DEPLOYMENT USING GITHUB ACTIONS, AWS ECR, AND AWS CODEDEPLOY

## GITHUB ACTIONS:
[Github Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions) enables you to create custom software development lifecycle workflows directly in your Github repository. These workflows are made of different tasks so-called actions that can be run automatically on certain events.



## AWS CODEDEPLOY:
[AWS Codedeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html) is a fully managed deployment service that automates software deployments to a variety of computing services such as Amazon EC2, AWS Fargate, AWS Lambda, and your on-premises servers.

# Prerequisites:
* A Github Repository with access to workflow
* A service role for CodeDeploy
* Provision of an IAM user
* An IAM instance profile
* AWS ECR access

## Process:
* Build(GitHub Actions)
* deploy(Code Deploy)

## A Github Repository with access to the workflow: 

* A Github Repository is your code version control system that hosts your code and where the workflow flow takes place. And used to build your application and push to image registries.

## A service role for CodeDeploy:

* In Amazon, service roles are used to grant permissions to an Amazon service so it can access Amazon resources. The policies that you attach to the service role determine which resources the service can access and what it can do with those resources. The service role you create for CodeDeploy must be granted the permissions required for your computing platform. If you deploy to more than one compute platform, create one service role for each.

## Provision of an IAM user:
* IAM policies grant the IAM user the access required to deploy an Amazon Lambda compute platform, an EC2/On-Premises compute platform, and an Amazon ECS compute platform.

## An IAM instance profile:
* Your Amazon EC2 instances need permission to access the Amazon S3 buckets or GitHub repositories where the applications are stored. To launch Amazon EC2 instances that are compatible with CodeDeploy, you must create an additional IAM role, an instance profile. 

## AWS ECR access:
    
* Amazon Elastic Container Registry (Amazon ECR) is an AWS-managed container image registry service that is secure, scalable, and reliable. Amazon ECR supports private repositories with resource-based permissions using AWS IAM.

## BUILD PROCESS(GITHUB ACTIONS):

**Following are the steps to create a docker image and pushing to external registries using Github actions.** 

* Login to the [wavemaker](http://www.wavemakeronline.com) site and create an application. On the top of the right, the **VCS** option can be used to push the project to version control tools. Under the **VCS**, select **Push to External Repo** to push the selected project to external repositories.
    

* The wavemaker asks for your confirmation to push the changes. Select Yes to push to the external repository.

* Push the changes by committing them. Wavemaker suggests you to give a proper commit message to summarize the change and select **ok** to proceed.
 
* Currently, wavemaker offers you different external repo types. Choose GitHub and provide the valid details to push the changes.

 * After giving the valid details, select **Export** to export your project to Github.

### Add the below files to the code repository to work with Github Actions and CodeDeploy services.

* Dockerfile
* Github workflow file(*.yml) 
* appspec.yml


* [Dockerfile](https://docs.docker.com/engine/reference/builder/) is a simple text file that consists of instructions to build Docker images. You can use the following Dockerfile for building a Docker image of the [Wavemaker-app](https://docs.wavemaker.com/learn/app-development/deployment/build-with-docker) and create Docker containers by using a multi-stage Dockerfile. 

```
FROM maven:3.8.1-jdk-11 as maven-java-node
ENV MAVEN_CONFIG=~/.m2
RUN mkdir -p /usr/local/content/node
WORKDIR /usr/local/content/node
ADD https://nodejs.org/dist/v12.22.3/node-v12.22.3-linux-x64.tar.gz .
RUN tar -xzf node-v12.22.3-linux-x64.tar.gz \
   && ln -s /usr/local/content/node/node-v12.22.3-linux-x64/bin/node /usr/local/bin/node \
   && ln -s /usr/local/content/node/node-v12.22.3-linux-x64/bin/npm /usr/local/bin/npm \
   && chown -R root:root /usr/local/content/node \
   && rm -fR node-v12.22.3-linux-x64.tar.gz
FROM maven-java-node as webapp-artifact
RUN mkdir -p /usr/local/content/app
ADD ./ /usr/local/content/app
WORKDIR /usr/local/content/app
ARG build_profile_name
ENV profile=${build_profile_name}
RUN  mvn clean install -P${profile}
FROM tomcat:9.0.62
COPY --from=webapp-artifact /usr/local/content/app/target/*.war /usr/local/tomcat/webapps/
```
     
* Here, Env will be passed while building the docker image using the YAML file.

* [Github workflow file(*.yml)](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) is used to configure GitHub Actions specified using this YAML files stored in the  **".github/workflows/ directory**".

## Let’s look into it step by step:
* The name of your action. GitHub displays the name in the Actions tab to help visually identify actions in each job.

    ```
    name: wavemaker app deployment
    ```

* To automatically trigger a workflow, use on to define which events can cause the workflow to run.

```
on:
 pull_request:
   types: [closed]
   branches:
     - 'branch name'
```     
* Here, we are configuring the actions and when there will be a pull request in a closed state on a specified branch, then only the action triggers, you can use more options like on push, etc.
You can use environment variables to store information that you want to reference in your workflow and these env variables contain the credentials stored in the GitHub secretes.
```
env:
 repo_name: ${{ secrets.REPO_NAME }}
 IMAGE_TAG: ${{ github.run_number }}
```

* Here, a specified repo name is used to store the created image and to perform push and pull operations. This repository name is stored in the GitHub secretes. As we are using AWS ECR, the repository should exist. Github.run_number helps in tagging the docker image and this is a GitHub variable.

* A workflow run is made up of one or more jobs, which run in parallel by default.

``` 
jobs:
 application_build_and_deploy:
   runs-on: ubuntu-latest
   steps:
      -
       name: Checkout
       uses: actions/checkout@v3
```

* Here in the job, we are configuring the os which is ubuntu and action defines to checkout the repository in the GitHub build a machine which is somewhere in the cloud.

* After checking out the code, in the next step with the help of the access key and secrete key which is stored in the GitHub secretes, we are login into the AWS IAM account and login into the Elastic Container Registry(ECR) to push the docker image.


``` 
     - name: Configure AWS credentials
       uses: aws-actions/configure-aws-credentials@v1
       with:
         aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
         aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
         aws-region: ${{ secrets.AWS_REGION }}       
     - name: Login to Amazon ECR
       id: login-ecr
       uses: aws-actions/amazon-ecr-login@v1
```

* After login into the ECR registry successfully, in the next step the docker image will be built and pushed to the ECR registry with the image tag. The Image tag is a run number which creates at the time of GitHub actions workflow starts. The Dockerfile env variable is passing here which is used to build the image.

```
     
     - name: Image Build and push
       uses: docker/build-push-action@v3
       with:
         context: .
         build-args: |
           build_profile_name=deployment
         push: true
         tags: ${{ steps.login-ecr.outputs.registry }}/${{ env.repo_name }}:${{ env.IMAGE_TAG }}
```

* After successfully building and pushing the docker image to the registry, this should be deployed in an AWS compute instance by calling the code deploy service.

### AWS CodeDeploy is a service that automates code deployments to Elastic Compute Cloud (EC2) and on-premises servers.

* Before going to further actions, let us configure the code deploy service.
In this process, we are going to integrate GitHub with codedeploy. 
To perform the codedeploy operation the following steps need to be done.

## A service role for CodeDeploy:

1. Sign in to the Amazon Web Services Management Console and open the IAM console [IAM Console](https://console.amazonaws.cn/iam/) and in the navigation pane, choose Roles, and then choose to **Create role**.

2. On the **Create role** page, choose **Amazon service**, and from the **Choose the service that will use this role** list, choose **CodeDeploy**.

3. From **Select your use case**, choose your use case EC2/On-Premises deployments, choose **CodeDeploy** and then choose **Permissions**.

4. On the **Attached permissions policy** page, the permission policy is displayed. **Choose Next: Tags**.

5. On the **Review** page, in **Role name**, enter a name for the service role and you can also give a description of the Role. To restrict this service role from access to some endpoints, in the list of roles, browse to and choose the role you created, and continue to the next step.

6. On the **Trust relationships** tab, choose **Edit trust relationship**.  You should see the following policy, which provides the service role permission to access all supported endpoints:  

```
           {
   "Version": "2012-10-17",
   "Statement": [
       {
           "Sid": "",
           "Effect": "Allow",
           "Principal": {
               "Service": [
                   "codedeploy.amazonaws.com.cn"
               ]
           },
           "Action": "sts:AssumeRole"
       }
   ]
```   
7. After successfully creating the policy, note the aws arn values to provide to the IAM user. 

## Provision of an IAM user:

**Follow these instructions to prepare an IAM user to use CodeDeploy:**

* Create an IAM user or use one associated with your Amazon account and grant the IAM user access to CodeDeploy—and Amazon services and actions CodeDeploy depends on—by copying the following policy and attaching it to the IAM user.

```          
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Sid": "CodeDeployAccessPolicy",
     "Effect": "Allow",
     "Action": [
       "autoscaling:*",
       "codedeploy:*",
       "ec2:*",
       "lambda:*",
       "ecs:*",
       "elasticloadbalancing:*",
       "iam:AddRoleToInstanceProfile",
       "iam:AttachRolePolicy",
       "iam:CreateInstanceProfile",
       "iam:CreateRole",
       "iam:DeleteInstanceProfile",
       "iam:DeleteRole",
       "iam:DeleteRolePolicy",
       "iam:GetInstanceProfile",
       "iam:GetRole",
       "iam:GetRolePolicy",
       "iam:ListInstanceProfilesForRole",
       "iam:ListRolePolicies",
       "iam:ListRoles",
       "iam:PutRolePolicy",
       "iam:RemoveRoleFromInstanceProfile",
       "s3:*",
       "ssm:*"
     ],
     "Resource": "*"
   },
   {
     "Sid": "CodeDeployRolePolicy",
     "Effect": "Allow",
     "Action": [
       "iam:PassRole"
     ],
     "Resource": "arn:aws:iam::account-ID:role/CodeDeployServiceRole"
   }
 ]
}
```



* In the preceding policy, replace **arn:aws:iam::account-ID:role/CodeDeployServiceRole** with the ARN value of the CodeDeploy service role that you created in the step of “**A service role for CodeDeploy**”. 

* You can find the ARN value on the details page of the service role in the IAM console.

* The preceding policy grants the IAM user the access required to deploy an Amazon Lambda compute platform, an EC2/On-Premises compute platform, and an Amazon ECS compute platform.

## An IAM instance profile:

1. In the IAM console, in the navigation pane, choose Policies,
 and then choose to Create policy by pasting the following in the and by navigating to **JSON** tab.

```
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": [
               "s3:Get*",
               "s3:List*"
           ],
           "Effect": "Allow",
           "Resource": "*"
       }
   ]
}
```


Choose a **Review policy** and create a policy by giving a name. Let us say it is **CodeDeployDemo-EC2-Permissions**.


2. the navigation pane, choose **Roles**, and then choose to **Create role**. Choose **Amazon service**, and from the **Choose the service that will use this role** list, choose **EC2**.

3. From the **Select, your use case** list, choose **EC2** and then Choose **Next: Permissions**.

4. In the list of policies, select the check box next to the policy you just created (**CodeDeployDemo-EC2-Permissions**). If necessary, use the search box to find the policy.


5. To use Systems Manager to install or configure the CodeDeploy agent, select the box next to **AmazonSSMManagedInstanceCore**. This Amazon-managed policy enables an instance to use Systems Manager service core functionality. If necessary, use the search box to find the policy. This policy is not needed if you plan to install the agent from the public Amazon S3 bucket with the command line.

6. Choose **Next: Tags** and On the **Review** page, in **Role name**, enter a name for the service role (for example,CodeDeployDemo-EC2-Instance-Profile), and then choose to Create role.

** You've now created an IAM instance profile to attach to your Amazon EC2 instances.**

## Installing CodeDeploy agent:

  * The [CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install.html) agent is a software package that, when installed and configured on an instance, makes it possible for that instance to be used in CodeDeploy deployments.

    * Follow the steps below to install the CodeDeploy agent on ec2 Ubuntu Server.

    1. Sign in to the instance and execute the following commands.

```
sudo apt-get update
wget https://aws-codedeploy-aws_region_name.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto > /tmp/logfile
sudo service codedeploy-agent status 
```

   2. **To check that the service is run** the following command:
   ```
               sudo service codedeploy-agent status       
   ```

    3. If the CodeDeploy agent is installed and not running, start the service by running the following command and checking the status.
```    
           sudo service codedeploy-agent start
```

### To use Elastic Container Registry, the IAM user and the instance profile roles should have the permissions. The following are the permissions and their description in brief:


* **AmazonEC2ContainerRegistryFullAccess**: This allows a user to perform any operation on your ECR repositories, including deleting them, and should therefore be left for system administrators and owners.

* **AmazonEC2ContainerRegistryPowerUser**: This allows a user to push and pull images on any repositories, which is very handy for developers that are actively building and deploying your software.

* **AmazonEC2ContainerRegistryReadOnly**: This allows a user to pull images on any repository, which is useful for scenarios where developers are not pushing their software from their workstation, and are instead just pulling internal dependencies to work on their projects.


### Based on your configuration, you can select any one of the following above. 


## Link a GitHub account to an application in CodeDeploy

1. Sign in to the Amazon Web Services Management Console and open the CodeDeploy [console](https://console.amazonaws.cn/codedeploy).

2. In **Deployment settings**, for **Revision type**, choose My **application is stored in GitHub**.

3. To create a connection for Amazon CodeDeploy applications to a GitHub account, sign out of GitHub in a separate web browser tab. In **GitHub token name,** type a name to identify this connection, and then choose **Connect to GitHub.** The web page prompts you to authorize CodeDeploy to interact with GitHub for your application. 

4. If you are not already signed in to GitHub, follow the instructions on the **Sign-in** page to sign in with the GitHub account to which you want to link the application.

5. Choose **Authorize application.** GitHub gives CodeDeploy permission to interact with GitHub on behalf of the signed-in GitHub account for the selected application.

6. In the navigation pane, expand **Deploy**, then choose **Applications**.

7. If your application does not have a deployment group, choose to **Create deployment** group to create one. A deployment group is required to choose to **Create deployment** in the next step.

8. From **Deployments**, choose to **Create deployment**.

### Till now we have integrated the Github with codedeploy service.

### Let’s configure and call the code deploy service in the GitHub actions workflow. 

* ***On the GitHub workflow yml file***,.Update the build number and repository name to the [System Manager Parameter Store (SSM)](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html).


* These credentials will be stored in the aws SSM store to use in the codedeploy service to pull the docker image from the ECR registry.
```

     - name: update build number and credentials 
       shell: bash
       run:  |
         aws ssm put-parameter --name "/github-ci-cd/repo" --type "String" --value ${{ env.repo_name }} --overwrite
         aws ssm put-parameter --name "/github-ci-cd/build_number" --type "String" --value ${{ env.IMAGE_TAG }} --overwrite
```         

* Create CodeDeploy deployment. This action will call the aws codedployement service which is used to deploy in the instance.
```
     - name: Create CodeDeploy Deployment
       shell: bash
       run: |
         aws deploy create-deployment --region ${{ secrets.AWS_REGION }} \
           --application-name wm-signup-application \
           --deployment-group-name wm-signup-deployment \
           --deployment-config-name CodeDeployDefault.OneAtATime \
           --github-location repository=${{ github.repository }},commitId=${{ github.sha }} 
```



## Updating Secrets in Github:

* The secretes can be update on gihub by navigating the follow:
* Github >> Repository >> Settings >> Secrets >> Actions.** 

## CodeDeploy Service:
* **appspec.yml**

    * The application specification file (AppSpec file) is a YAML -formatted or JSON-formatted file used by CodeDeploy to manage a deployment.

    * The AppSpec file for an EC2/On-Premises deployment must be named appspec. yml or appspec. yaml , unless you are performing a local deployment.

```
version: 0.0
os: linux
#The files will export to the path given in the destination and if the files already exist, overwrite them.
files:
 - source: .
   destination: /home/ubuntu/github-actions/
file_exists_behavior: OVERWRITE
#The 'hooks' section for an EC2/On-Premises deployment contains mappings that link deployment lifecycle event hooks to one or more scripts.
#If an event hook is not present, no operation is executed for that event.
hooks:
 AfterInstall:
  - location: login.sh 
    timeout: 300  #in seconds
    runas: root  #runs as a root user
 ApplicationStart:
  - location: run.sh
    timeout: 300 #runs as a root user
    runas: root
```    

* The **login.sh** script contains the information about to login into the aws ecr registry and this will contains the following information.

```
#!/bin/bash
#to get login into the aws Elastic Container Registry
#This will give us the aws account name.
account_id=$(aws sts get-caller-identity | jq -r .Account)
#This will gives us the region name
region_name=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
 
#login into the ECR
aws ecr get-login-password --region $region_name | docker login --username AWS --password-stdin $account_id.dkr.ecr.$region_name.amazonaws.com
```
 
* After login successfully, running the **run.sh** script which is responsible for pulling the image from the ECR and running the docker container.
```
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
#removing unwanted docker images
sudo docker images prune -a

```


**You can view the deployment logs in the location: /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log**
