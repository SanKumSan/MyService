let "randomIdentifier=$RANDOM*$RANDOM"
location="germanywestcentral"
resourceGroup="test-script1-rg"

tag="script-action-tag"
servicePrincipal="test-script1-sp-sancr7-test1" # Must be unique within your AD tenant
containerRegistry="test-script1-con-reg"
registrySku="Basic"

# Create a resource group
echo "Creating $resourceGroup at "$location"..."
az group create --name $resourceGroup --location "$location" --tag $tag
echo "Created $resourceGroup at "$location"..."

# Create a container registry
echo "Creating container registry $containerRegistry with sku=$registrySku"
az acr create --resource-group $resourceGroup --name $containerRegistry --sku $registrySku
echo "Created containerRegistry $containerRegistry"

# Modify for your environment.
# ACR_NAME: The name of your Azure Container Registry
# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_NAME=$servicePrincipal

# Obtain the full registry ID
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
echo "reg id = $registryId"

# Create the service principal with rights scoped to the registry.
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role owner --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $USER_NAME"
echo "Service principal password: $PASSWORD"
# </Create>
SERVICE_PRINCIPAL_ID=$USER_NAME
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_ID=$servicePrincipal

# Populate value required for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role owner

echo "All scripts steps done"

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y