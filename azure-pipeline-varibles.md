# azure pipeline variables

- repository_name: image repository name of webapp, example : webapp
- acr_service_name: azure container registry service name
- aks_service_name: azure kubernetes service name
- acr_registry: name if azure container registry, example mypipeline.azurecr.io
- az_subcription_service: azure resource manager service name
- storage_account_name: name of storage account
- maven_build_profile: maven build profile name, example deployment
- no_of_webapp_repicas: no of web application replicas
- default_database_container: provide **yes** to deploy the database container also , **no** for not deploying database container
- prod_namespace: namespace of prod branch for deploy an application
- uat_namespace: namespace of UAT branch for deploy application
- application_name: name of the application for ingress service context for doing path based routing

- uat_env_cdn_url : cdn url for uat env , example: https://myuatcdn.azureedge.net/myuatcontainer/ng-bundle/
- prod_env_cdn_url : cdn url for prod env, example: https://myprodcdn.azureedge.net/myprodcontainer/ng-bundle/
- uat_container_blob: uat env container name
- prod_container_blob: prod env container name
- uat_env_hostname: host name for uat env , example : myuatapp.domain.com
- tls_secret_name: tls secret name for host domaina
- unique_name_for_application: name of application for uniqueness , name must be small letters and doesn't include underscore(_)
- prod_env_host_name: prod env host name , example : myprodapp.domain.com
