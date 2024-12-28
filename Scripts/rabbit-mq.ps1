# Variables
$ResourceGroupName = "acr_actions"
#$Location = "germanywestcentral"
$EnvironmentName = "my-test-virtual-env"
$AppName = "rabbitmq-cont-app"
$Image = "rabbitmq:3-management"
$Cpu = "0.5"
$Memory = "1.0Gi"
$Ingress = "external"
$TargetPort = 15672
$EnvVars = @{
    RABBITMQ_DEFAULT_USER = "admin"
    RABBITMQ_DEFAULT_PASS = "admin"
}

# Create Resource Group
#az group create --name $ResourceGroupName --location $Location

# Create Azure Container App Environment
#az containerapp env create --name $EnvironmentName --resource-group $ResourceGroupName --location $Location

# Deploy RabbitMQ Container
az containerapp create `
    --name $AppName `
    --resource-group $ResourceGroupName `
    --environment $EnvironmentName `
    --image $Image `
    --target-port $TargetPort `
    --ingress $Ingress `
    --cpu $Cpu `
    --memory $Memory `
    --env-vars @($EnvVars.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" })

# Output FQDN
$Fqdn = az containerapp show --name $AppName --resource-group $ResourceGroupName --query properties.configuration.ingress.fqdn -o tsv
Write-Host "RabbitMQ container app deployed at: $Fqdn"