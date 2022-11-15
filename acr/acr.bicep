param location string = resourceGroup().location
param acrname string
param identity string
param KeyIdentifier string
param userAssignedIdentitiesName string
var userAssignedIdentitiesId = concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', userAssignedIdentitiesName)

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrname
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {

      '${userAssignedIdentitiesId}': {}

    }
  }
  properties: {
    zoneRedundancy: 'Enabled'
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: '205.189.242.100/32'
        }
      ]
    }
    encryption: {
      status: 'enabled'
      keyVaultProperties: {
        identity: identity
        keyIdentifier:  KeyIdentifier
      }
    }
    policies: {
      exportPolicy: {
        status: 'enabled'
      }
    }
  }
}

output acr string = acr.id
