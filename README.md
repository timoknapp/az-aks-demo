# az-demo-fn

![architecture](architecture.png)

## Prerequisites

* Azure CLI version 2.47.0 or later
* kubectl
* Helm version 3.0 or later
* jq

Following the following tutorials:

* [AKS + Application Gateway (excluding Application Gateway Ingress Controller parts)](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new)
* [Ingress Web Application Routing](https://learn.microsoft.com/en-us/azure/aks/web-app-routing?tabs=without-osm)

## Getting started

### Create a service principal

```bash
subscriptionId=$(az account show --query "id" -o tsv)

az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$subscriptionId -o json > auth.json

appId=$(jq -r ".appId" auth.json)
password=$(jq -r ".password" auth.json)
objectId=$(az ad sp show --id $appId --query "id" -o tsv)
cat <<EOF > parameters.json
{
  "aksServicePrincipalAppId": { "value": "$appId" },
  "aksServicePrincipalClientSecret": { "value": "$password" },
  "aksServicePrincipalObjectId": { "value": "$objectId" },
  "aksEnableRBAC": { "value": true }
}
EOF
```

### Deploy Resources to Azure

```bash
resourceGroupName="rg-aks-demo-freenow-001"
location="westeurope"
deploymentName="aks-demo-freenow-001"

# create a resource group
az group create -n $resourceGroupName -l $location

# modify the template as needed
az deployment group create \
        -g $resourceGroupName \
        -n $deploymentName \
        --template-file main.bicep \
        --parameters parameters.json

az deployment group show -g $resourceGroupName -n $deploymentName --query "properties.outputs" -o json > deployment-outputs.json
```

### Install Azure AD Pod Identity

```bash
kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml
```

### Install Web Application Routing Ingress Controller

```bash
TODO
```

### Install a sample App

```bash
curl https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml -o aspnetapp.yaml

kubectl apply -f aspnetapp.yaml
```

### TODOs

* Application Gateway with one Backend Pool pointing to AKS Ingress Controller
* AKS Api Server VNET integration
* ~~Azure AD Pod Identity~~
* ~~Postgres Flexible Server~~
* ~~Storage Account~~
* ~~Redis Cache~~
* ~~Container Registry~~
* ~~Log Analytics Workspace~~
* (AKS KEDA Addon)
