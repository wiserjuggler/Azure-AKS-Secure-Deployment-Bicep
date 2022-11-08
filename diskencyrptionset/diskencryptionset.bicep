@description('Name of the Disk encyrption set')
param DiskEncryptionSetName string

@description('Resource Group Location')
param location string = resourceGroup().location

param keyUrl string 
param KeyVaultId string

resource diskencyptionset 'Microsoft.Compute/diskEncryptionSets@2022-07-02' = {
  name: DiskEncryptionSetName
  location: location
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    encryptionType: 'EncryptionAtRestWithCustomerKey'
    rotationToLatestKeyVersionEnabled: false
    activeKey: {
      sourceVault: {
        id: KeyVaultId
      }
      keyUrl: keyUrl
    }
  }
}

output keyName string = diskencyptionset.name
output principalId string = diskencyptionset.identity.principalId
output desId string = diskencyptionset.id
