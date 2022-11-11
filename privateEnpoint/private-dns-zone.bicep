@description('The name of the virtual network to create.')
param virtualNetworkName string

@description('The id of the vnet to create the dns on')
param vnetId string

param privateDnsZoneName string
var privateDnsZoneLinkName = 'link-to-${virtualNetworkName}'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZone_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: privateDnsZoneLinkName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

output privateDnsZoneName string = privateDnsZone.name
output privateDnsZoneId string = privateDnsZone.id
