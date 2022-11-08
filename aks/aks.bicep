param  AksClusterName string
param location string = resourceGroup().location
param kubernetesVersion string = '1.23.12'
param diskEncryptionSetID string
param dnsPrefix string
param LogAnalyticsWorkSpaceId string
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

resource akscluster 'Microsoft.ContainerService/managedClusters@2022-09-02-preview' = {
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
  }
}
