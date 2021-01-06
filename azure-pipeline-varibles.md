# azure pipeline variables

- **uat_repository_name**: image repository name of webapp in UAT environment, example : uatwebapp
- **prod_repository_name**: image repository name of webapp PROD environment  , example prodwebapp
- **acr_service_name**: azure container registry service name
- **aks_service_name**: azure kubernetes service name
- **acr_registry**: name if azure container registry, example mypipeline.azurecr.io
- **az_subcription_service**: azure resource manager service name
- **storage_account_name**: name of storage account
- **uat_maven_build_profile**: maven build profile name for UAT environment, example myuatdeployment
- **prod_maven_build_profile**: maven build profile name for PROD environment, example myproddeployment
- **no_of_webapp_repicas**: no of web application replicas
- **default_database_container**: provide **yes** to deploy the database container also , **no** for not deploying database container
- **prod_namespace**: namespace of PROD branch for deploy an application
- **uat_namespace**: namespace of UAT branch for deploy application
- **application_name**: name of the application for ingress service context for doing path based routing

- **uat_env_cdn_url** : cdn url for UAT Env , example: `https://myuatcdn.azureedge.net/myuatcontainer`
- **prod_env_cdn_url** : cdn url for PROD Env, example: `https://myprodcdn.azureedge.net/myprodcontainer`
- **uat_container_blob**: UAT Env container name for static content storage
- **prod_container_blob**: PROD Env container name for static content storage
- **uat_env_hostname**: host name for UAT Env , example : myuatapp.domain.com
- **tls_secret_name**: tls secret name for host domain SSL configurations
- **unique_name_for_application**: name of application for uniqueness , name must be small letters and doesn't include underscore(_) and must be **`unique across cluster`**
- **prod_env_host_name**: PROD Env host name , example : myprodapp.domain.com
- **uat_website_private_key_filename**: website ssl private key filename in secure files for UAT
- **uat_website_bundle_certificate_filename**: website ssl bundle certificate and CA cert combination file name in secure files for UAT Env website
- **prod_website_private_key_filename**: website ssl private key filename in secure files for PROD
- **prod_website_bundle_certificate_filename**: website ssl bundle certificate and CA cert combination file name in secure files for PROD Env website
