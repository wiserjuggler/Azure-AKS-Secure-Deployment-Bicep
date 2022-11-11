param privateEndpointSubnetId string
param linkedServiceId string
param groupIds array
param location string = resourceGroup().location
param privateDnsZoneName string
param DnsZoneId string

param privateEndpointName string
param DnsZoneConfigName string

var pvtEndpointDnsGroupName = '${privateEndpointName}/${privateDnsZoneName}'


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    customNetworkInterfaceName: '${privateEndpointName}-nic'
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: linkedServiceId
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
          groupIds: groupIds
        }
      }
    ]
  }
}


resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: DnsZoneConfigName
        properties: {
          privateDnsZoneId: DnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

// resource dnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' =  {
//   name: '${privateDnsZoneName}/${aRecordName}'
//   properties:{
//     ttl: 600
//     aRecords: [
//       {
//         ipv4Address: first(privateEndpoint.properties.customDnsConfigs[0].ipAddresses)
//       }
//     ]
//   }
// }
