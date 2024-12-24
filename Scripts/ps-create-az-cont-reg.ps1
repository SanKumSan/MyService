# Random Identifier
#$randomIdentifier = Get-Random -Minimum 1 -Maximum 10000
$location = "germanywestcentral"
$resourceGroup = "test-script1-rg"
$tag = "script-action-tag"
$servicePrincipal = "test-script1-sp-sancr7" # Must be unique within your AD tenant
$containerRegistry = "test-script1-con-reg"
$registrySku = "Basic"

# Step 1: Create a Resource Group
Write-Host "Creating resource group $resourceGroup at $location..."
az group create --name $resourceGroup --location $location --tag $tag
Write-Host "Created resource group $resourceGroup at $location."

# Step 2: Create a Container Registry
Write-Host "Creating container registry $containerRegistry with sku=$registrySku..."
az acr create --resource-group $resourceGroup --name $containerRegistry --sku $registrySku
Write-Host "Created container registry $containerRegistry."

# Step 3: Obtain the Full Registry ID
Write-Host "Obtaining the registry ID for $containerRegistry..."
$acrRegistryId = az acr show --name $containerRegistry --query "id" --output tsv
Write-Host "Registry ID: $acrRegistryId"

# Step 4: Create the Service Principal
Write-Host "Creating service principal $servicePrincipal..."
$password = az ad sp create-for-rbac --name $servicePrincipal --scopes $acrRegistryId --role owner --query "password" --output tsv
$userName = az ad sp list --display-name $servicePrincipal --query "[].appId" --output tsv

Write-Host "Service principal created."
Write-Host "Service principal ID: $userName"
Write-Host "Service principal password: $password"

# Step 5: Assign Owner Role to the Service Principal
Write-Host "Assigning owner role to service principal $servicePrincipal for registry $containerRegistry..."
az role assignment create --assignee $userName --scope $acrRegistryId --role owner
Write-Host "Role assignment complete."

Write-Host "All script steps completed."

# Uncomment the following line if you want to delete the resources after execution:
# az group delete --name $resourceGroup --yes --no-wait