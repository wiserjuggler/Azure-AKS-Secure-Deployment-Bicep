@description('Location for all resources.')
param location string = resourceGroup().location

@description('CIDR range for the vnet.')
param vnetCidrPrefix string 

@description('The name of the AKS Cluster subnet.')
param AKSClusterSubnetName string 

@description('The name of the AKS Management Subnet.')
param AKSManagementSubnetName string 

@description('The name of the Azure Bastion Subnet.')
param AzureBastionSubnetName string 

@description('The name of the virtual network to create.')
param vnetName string 

@description('The name of the AKS Cluster NSG.')
param AKSClusternsg string 

@description('The name of the AKS Management NSG.')
param AKSManagementnsg string 

@description('The name of the Azure Bastion NSG.')
param AzureBastionnsg string 

@description('ID of the AKS Clutser Route Table')
param AKSClusterroutetableid string

@description('ID of the AKS Management Route Table')
param AKSManagementroutetableid string


resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetCidrPrefix}.0.0/21'
      ]
    }
    subnets: [
      {
        name: AKSClusterSubnetName
        properties: {
          addressPrefix: '${vnetCidrPrefix}.0.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          networkSecurityGroup: {
            id: AKSClusternsg
          }
          routeTable: {
            id: AKSClusterroutetableid
          }
        }
      }
      {
        name: AKSManagementSubnetName
        properties: {
          addressPrefix: '${vnetCidrPrefix}.4.0/26'
          networkSecurityGroup: {
            id: AKSManagementnsg
          }
          routeTable: {
            id: AKSManagementroutetableid
          }
        }
      }
      {
        name: AzureBastionSubnetName
        properties: {
          addressPrefix: '${vnetCidrPrefix}.4.64/26'
          networkSecurityGroup: {
            id: AzureBastionnsg
          }
        }
      }
    ]
  }
}