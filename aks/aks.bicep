param  AksClusterName string
param location string = resourceGroup().location
param kubernetesVersion string = '1.23.12'
param diskEncryptionSetID string
param dnsPrefix string
param LogAnalyticsWorkSpaceId string
param vnetSubnetID string
param nodeResourceGroup string
param userAssignedIdentitiesName string
var userAssignedIdentitiesId = concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', userAssignedIdentitiesName)
param agentPoolProfiles array = [
  {
    name: 'agentpool'
    count: 2
    minCount: 1
    maxCount: 2
    vmSize: 'Standard_B2s'
    osType: 'Linux'
    mode: 'System'
    // availabilityZones: [
    //   '1'
    //   '2'
    //   '3'
    // ]
    type: 'VirtualMachineScaleSets'
    storageProfile: 'ManagedDisks'
    enableAutoScaling: true
    vnetSubnetID: vnetSubnetID
  }
]

resource akscluster 'Microsoft.ContainerService/managedClusters@2022-09-01' = {
  name: AksClusterName
  location: location
  identity: {

    type: 'UserAssigned'

    userAssignedIdentities: {

      '${userAssignedIdentitiesId}': {}

    }

  }
  properties: {
    nodeResourceGroup: nodeResourceGroup
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
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'false'
          rotationPollInterval: '2m'
        }
      }
    }
  }
}

output aksclusterid string = akscluster.id
output aksclustername string = akscluster.name
