param location string = resourceGroup().location
param computerName string
param subnetid string
param adminUsername string = 'aksadminuser'

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${computerName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${computerName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetid
          }
        }
      }
    ]
  }
}


resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: computerName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: 'aksadminuser@12345'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${computerName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}
