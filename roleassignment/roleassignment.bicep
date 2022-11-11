
param SubnetID string
param AksPrincipalId string
param subscriptionId string = subscription().id
param roleDefinitionId string = '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'

resource akssubnetroleassigment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: 'AKSSubnetRoleAssignment'
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: AksPrincipalId
    principalType: 'ServicePrincipal'
    scope: SubnetID
  }
}
