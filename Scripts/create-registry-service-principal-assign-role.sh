#!/bin/bash
# Passed validation in Cloud Shell on 1/13/2022

# <FullScript>
# Create resource group and container registry

# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="germanywestcentral"
resourceGroup="test-action-reg-rg-$randomIdentifier"

tag="create-registry-service-principal-assign-role"
servicePrincipal="msdocs-acr-service-principal-$randomIdentifier" # Must be unique within your AD tenant
containerRegistry="test-action-coreg$randomIdentifier"
registrySku="Basic"

# Create a resource group
echo "Creating $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tag $tag
echo "Created $resourceGroup in "$location"..."

# Create a container registry
echo "Creating $containerRegistry with sku=$registrySku"
az acr create --resource-group $resourceGroup --name $containerRegistry --sku $registrySku
echo "Created containerRegistry $containerRegistry"

# Create service principal with rights scoped to the registry
# <Create>
#!/bin/bash
# This script requires Azure CLI version 2.25.0 or later. Check version with `az --version`.

# Modify for your environment.
# ACR_NAME: The name of your Azure Container Registry
# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_NAME=$servicePrincipal

# Obtain the full registry ID
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
echo "reg id = $registryId"

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role owner --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $USER_NAME"
echo "Service principal password: $PASSWORD"
# </Create>
SERVICE_PRINCIPAL_ID=$USER_NAME
# Use an existing service principal
# <Assign>
#!/bin/bash
# Modify for your environment. The ACR_NAME is the name of your Azure Container
# Registry, and the SERVICE_PRINCIPAL_ID is the service principal's 'appId' or
# one of its 'servicePrincipalNames' values.
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_ID=$servicePrincipal

# Populate value required for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

# Assign the desired role to the service principal. Modify the '--role' argument
# value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role owner
# </Assign>
# </FullScript>

echo "All scripts steps done"

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y
