param managedIdentityName string
param VnetName string
param roleDefinitionId string

// resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
//   name: VnetName
// }



resource akssubnetroleassigment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(VnetName)
  // scope: virtualNetwork
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: guid(managedIdentityName)
    principalType: 'ServicePrincipal'
  }
}
