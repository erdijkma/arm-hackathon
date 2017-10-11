# Variables
$AzureLocation = "West Europe"
$ResourceGroupNameKeyVault = "arm-hackathon-rg"
$KeyVaultResType = "Microsoft.KeyVault/vaults" # required to lock KeyVault object
$saResType = "Microsoft.Storage/storageAccounts" # required to lock SA Object

# Login to Azure
Login-AzureRmAccount

# Get the subscriptions assigned to account
$subscriptions = Get-AzureRmSubscription

# Prompt for Azure Subscription to use
$subscription = $subscriptions | Out-GridView -Title "Please select the Subscription you want to use" -OutVariable Single -PassThru

# Set the chosen subcription 
Set-AzureRmContext -SubscriptionId $subscription.Id


# Create Key Vault
$keyVaultName = Read-Host -Prompt "Please Enter the Key Vault Name (must be Unique in Azure)"
$azureKeyVault = New-AzureRmKeyVault -VaultName $keyVaultName -Location $AzureLocation -ResourceGroupName $ResourceGroupNameKeyVault

# Add VM Admin Credentials to Key Vault
Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name "VMAdminPassword" -SecretValue (Get-Credential).Password | Out-Null

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -EnabledForDeployment -EnabledForTemplateDeployment

# Lock the KeyVault Object
New-AzureRmResourceLock -LockLevel CanNotDelete -LockName "LockKeyVault" -ResourceName $azureKeyVault.VaultName -ResourceType $KeyVaultResType -ResourceGroupName $azureKeyVault.ResourceGroupName -force 

