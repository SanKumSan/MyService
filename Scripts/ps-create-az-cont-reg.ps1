# Random Identifier
#$randomIdentifier = Get-Random -Minimum 1 -Maximum 10000
$location = "germanywestcentral"
$resourceGroup = "testscriptrg"
$tag = "scriptactiontag"
$servicePrincipal = "github-action-1" # Must be unique within your AD tenant
$containerRegistry = "testscriptoneconreg"
$registrySku = "Basic"

# Step 1: Create a Resource Group
#Write-Host "Creating resource group $resourceGroup at $location..."
az group create --name $resourceGroup --location $location --tag $tag
Write-Host "Created resource group $resourceGroup at $location."

# Step 2: Create a Container Registry
#Write-Host "Creating container registry $containerRegistry with sku=$registrySku..."
az acr create --resource-group $resourceGroup --name $containerRegistry --sku $registrySku
Write-Host "Created container registry: $containerRegistry."

# Step 4: Create the Service Principal
#Write-Host "Creating service principal $servicePrincipal..."
#$password = az ad sp create-for-rbac --name $servicePrincipal --scopes $acrRegistryId --role owner --query "password" --output tsv
#$userName = az ad sp list --display-name $servicePrincipal --query "[].appId" --output tsv
# ************************************
# Step 3: Obtain the Full Registry ID
Write-Host "Obtaining the registry ID for $containerRegistry..."
$acrRegistryId = az acr show --name $containerRegistry --query "id" --output tsv
if (!$acrRegistryId) {
    Write-Host "Failed to retrieve the registry ID. Exiting..." -ForegroundColor Red
    exit 1
}
Write-Host "Get Registry ID: $acrRegistryId"

# Step 4: Retrieve the Service Principal App ID
Write-Host "Retrieving app ID for service principal : $servicePrincipal..."
$appId = az ad sp list --display-name $servicePrincipal --query "[].appId" --output tsv
if (!$appId) {
    Write-Host "Service principal $servicePrincipal not found. Exiting..." -ForegroundColor Red
    exit 1
}
Write-Host "Service principal app ID: $appId"

# Step 5: Assign Owner Role to the Service Principal
Write-Host "Assigning owner role to service principal $servicePrincipal for registry $containerRegistry..."
try {
    az role assignment create --assignee $appId --scope $acrRegistryId --role owner
    Write-Host "Role assignment complete."
} catch {
    Write-Host "Error assigning role to service principal: $_" -ForegroundColor Red
    exit 1
}

Write-Host "All script steps completed successfully."
