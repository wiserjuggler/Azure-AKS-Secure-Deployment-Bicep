param ManagedIdentityName string
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: ManagedIdentityName
  location: location
}
output ManagedIdentityID string = managedIdentity.id
output ManagedIdentityClientID string = managedIdentity.properties.clientId
output ManagedIdentityName string = managedIdentity.name
output ManagedIdentityPrincipalID string = managedIdentity.properties.principalId
