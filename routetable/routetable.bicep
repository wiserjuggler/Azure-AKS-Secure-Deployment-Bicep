@description('Resource Group location')
param location string = resourceGroup().location

@description('CIDR of the Firewall')
param AzureFirewallCidr string

@description('Name of the AKS Management Route Table')
param RouteTableName string

resource routetable 'Microsoft.Network/routeTables@2022-05-01' = {
  name: RouteTableName
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'AllTrafficToFirewall'
        properties: {
          hasBgpOverride: false
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: AzureFirewallCidr
          nextHopType: 'VirtualAppliance'
          
      }
    }
    ]
  }
}

output routetableid string = routetable.id
