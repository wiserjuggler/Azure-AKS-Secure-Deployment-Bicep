param location string = resourceGroup().location
param acrname string

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrname
  location: location
  sku: {
    name: 'Premium'
  }
}

output acr string = acr.id
