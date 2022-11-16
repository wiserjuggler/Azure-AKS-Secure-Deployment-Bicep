param AksClusterName string
param acrname string

var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource aks 'Microsoft.ContainerService/managedClusters@2022-09-01' existing = {
  name: AksClusterName
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: acrname
} 

resource acrpullrole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aks.id, acrPullRoleDefinitionId)
   scope: acr
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}
