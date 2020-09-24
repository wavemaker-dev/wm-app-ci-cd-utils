#!/bin/bash
set -e
file_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $file_location


while getopts p:i:c:o:f:b:h:l:L:C:s:e:a:r:P:B:d:A:R:n: options
do 
    case "${options}" in
       # j) JOB_NAME=${OPTARG};;
        P) mvn_build_profile=${OPTARG};;
        i) docker_image_name=${OPTARG};;
        c) docker_registry_uri=${OPTARG};;
        o) operation=${OPTARG};;
        f) sonarqube_frontend_analysis_projectkey=${OPTARG};;
        b) sonarqube_backend_analysis_projectkey=${OPTARG};;
        h) sonarqube_server_url=${OPTARG};;
        l) sonarqube_backend_analysis_login_id=${OPTARG};;
        L) sonarqube_frontend_analysis_login_id=${OPTARG};;
        C) CDN_URL=${OPTARG};;
        s) S3_BUCKET=${OPTARG};;
        e) EKS_CLUSTER_NAME=${OPTARG};;
        a) application_url=${OPTARG};;
        r) remoteDriverUrl=${OPTARG};;
        P) remote_browser_port=${OPTARG};;
        B) browser=${OPTARG};;
        d) default_database=${OPTARG};;
        A) app_context=${OPTARG};;
        R) webapp_replicas=${OPTARG};
        n) project_name=${OPTARG};


    esac
done

# sonarqube analysis
sonarqube_analysis() {
    mvn clean verify sonar:sonar  -Dsonar.projectKey=$sonarqube_backend_analysis_projectkey   -Dsonar.host.url=$sonarqube_server_url   -Dsonar.login=$sonarqube_backend_analysis_login_id
    sonar-scanner   -Dsonar.projectKey=$sonarqube_frontend_analysis_projectkey   -Dsonar.sources=.   -Dsonar.host.url=$sonarqube_server_url   -Dsonar.login=$sonarqube_frontend_analysis_login_id
}


# build image , tag and push the image to specified docker registry and copying the deploying scripts to job location
mvn_and_docker_build() {
    mvn clean install -P$mvn_build_profile -Dcdn-url=$CDN_URL
    mkdir static_content
    unzip target/ui-artifact.zip -d static_content/
    aws s3 sync static_content/ $S3_BUCKET
    docker image build -t $docker_image_name .
    
}

kubernetes_deploy() {
    aws eks update-kubeconfig --name $EKS_CLUSTER_NAME
    aws ecr get-login-password  | docker login --username AWS --password-stdin $docker_registry_uri
    docker tag $docker_image_name $docker_registry_uri:$BUILD_NUMBER
    docker push $docker_registry_uri:$BUILD_NUMBER
    sed -i 's@CONTAINER_IMAGE@'"$docker_registry_uri:$BUILD_NUMBER"'@' k8s-manifestfiles/wm_app_webapp.yml
    sed -i '/replicas/  s/1/'"$webapp_replicas"'/g' k8s-manifestfiles/wm_app_webapp.yml
    sed -i 's/APP_NAME/'"$project_name"'/g' k8s-manifestfiles/*
    if [ "$default_database" == "yes" ]
    then
        kubectl apply -f ./k8s-manifestfiles/
    else
        kubectl apply -f k8s-manifestfiles/wm_app_config_and_secret.yml
        kubectl apply -f k8-manifestfiles/wm_app_webapp.yml
        kubectl apply -f k8-manifestfiles/wm_app_loadbalancer.yml
    fi
    LoadBalancer_url=$(kubectl get svc wmapploadbalancersvc-$project_name --output="jsonpath={.status.loadBalancer.ingress[0].hostname}")
    echo "aws ELB access url :  http://$LoadBalancer_url/$app_context"
}

app_test_cases() {
    mvn clean install -Denv.baseurl=$application_url -Denv.remoteDriverPort=$remote_browser_port -Denv.remoteDriverUrl=$remoteDriverUrl -Denv.browser=$browser

}


if [ "$#" -gt 1 ]
then
    case "$operation" in
        sonarqube)
                sonarqube_analysis
                ;;
        build)
                mvn_and_docker_build
                ;;
        deploy)
                kubernetes_deploy
                ;;
        test)
                app_test_cases
                ;;
    esac
fi

#operation in master
#  /var/jenkins_home/workspace/$JOB_NAME/
# sonarqube
# mvn clean verify sonar:sonar  -Dsonar.projectKey=$sonarqube_backend_analysis_projectkey   -Dsonar.host.url=$sonarqube_server_url   -Dsonar.login=$sonarqube_backend_analysis_login_id
# sonar-scanner   -Dsonar.projectKey=$sonarqube_frontend_analysis_projectkey   -Dsonar.sources=.   -Dsonar.host.url=$sonarqube_server_url   -Dsonar.login=$sonarqube_frontend_analysis_login_id
# sonarqube command
# bash jenkins_operations.sh -o sonarqube