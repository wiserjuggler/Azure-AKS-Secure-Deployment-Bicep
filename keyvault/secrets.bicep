param keyVaultName string
@secure()
param secrets object
resource keyvaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = [for item in secrets.items: {
  name: '${keyVaultName}/${item.name}'
  properties: {
    value: item.value
  }
}]
