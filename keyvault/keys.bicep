param keyVaultName string
param keyName string
param keySize int

resource key 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  name: '${keyVaultName}/${keyName}'
  properties: {
    kty: 'RSA-HSM'
    keySize: keySize
    keyOps: [
      'encrypt'
      'decrypt'
      'wrapKey'
      'unwrapKey'
      'sign'
      'verify'
    ]
    attributes: {
      enabled: true
    }
  }
}

output KeyUrl string = key.properties.keyUriWithVersion
