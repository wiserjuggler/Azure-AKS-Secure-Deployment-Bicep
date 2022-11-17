targetScope = 'resourceGroup'

@minLength(3)
@maxLength(24)
param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param keyVaultName string

@description('The name of the virtual network to create.')
param vnetName string 

@description('The name of the private endpoint subnet')
param privateEndpointSubnetName string 

// var randomstring = take(uniqueString(resourceGroup().id),4)

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${keyVaultName}qktw'
  location: location
  properties: {
    enableSoftDelete: true
    enabledForDeployment: false
    enablePurgeProtection: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    softDeleteRetentionInDays:90
    tenantId: tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
        }
      ]
      ipRules: [ {
        value: '205.189.242.100/32'
      }
      ]
    }
    accessPolicies: []
    sku: {
      name: 'premium'
      family: 'A'
    }
  }
}


output KeyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
        