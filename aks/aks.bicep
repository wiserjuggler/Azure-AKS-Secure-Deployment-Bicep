param  AksClusterName string
param location string = resourceGroup().location
param kubernetesVersion string = '1.23.12'
param diskEncryptionSetID string
param dnsPrefix string
param LogAnalyticsWorkSpaceId string
param privateEndpointName string = '${AksClusterName}-privateEndpoint'

@description('The name of the virtual network to create.')
param vnetName string 

@description('The name of the private endpoint subnet')
param privateEndpointSubnetName string 

param agentPoolProfiles array = [
  {
    name: 'agentpool'
    count: 2
    minCount: 1
    maxCount: 2
    vmSize: 'Standard_DS2_v2'
    osType: 'Linux'
    mode: 'System'
    enableAutoScaling: true
  }
]

resource akscluster 'Microsoft.ContainerService/managedClusters@2022-09-01' = {
  name: AksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    diskEncryptionSetID: diskEncryptionSetID
    enableRBAC: true
    agentPoolProfiles: agentPoolProfiles
    dnsPrefix: dnsPrefix
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: LogAnalyticsWorkSpaceId
        securityMonitoring: {
          enabled: true
        }
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceId: LogAnalyticsWorkSpaceId
        }
      }
      azurepolicy: {
        enabled: true
        config: {
          version: 'v2'
        }
      }
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    customNetworkInterfaceName: '${privateEndpointName}-nic'
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: akscluster.id
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
  }
}

