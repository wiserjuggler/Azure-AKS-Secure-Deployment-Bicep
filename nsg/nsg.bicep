@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the AKS Cluster subnet.')
param AKSClusterSubnetName string 

@description('The name of the AKS Management Subnet.')
param AKSManagementSubnetName string 

@description('The name of the Azure Bastion Subnet.')
param AzureBastionSubnetName string


resource aksclusternsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${AKSClusterSubnetName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Inbound-AllowManagement'
        properties: {
          description: 'Allow jumpbox'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Inbound-DenyAll'
        properties: {
          description: 'Deny All Inbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource aksmanagementnsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${AKSManagementSubnetName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Inbound-DenyAll'
        properties: {
          description: 'Deny All Inbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource azurebastionnsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${AzureBastionSubnetName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          description: 'Azure Bastion NSG requirement to Allow Https Inbound from Internet'
          protocol: 'Tcp'
          sourcePortRange: '443'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          description: 'Allow gateway Manager'
          protocol: 'Tcp'
          sourcePortRange: '443'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          description: 'Allow Azure Load Balancer Inbound'
          protocol: 'TCP'
          sourcePortRange: '443'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRanges: [
            '8080'
            '5701'
          ]
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'Inbound-DenyAll'
        properties: {
          description: 'Deny All Inbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          description: 'Deny All Inbound'
          protocol: '*'
          sourcePortRanges: [
            '22'
            '3389'
          ]
          destinationPortRanges:[
            '22'
            '3389'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'outbound'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          description: 'Deny All Inbound'
          protocol: 'TCP'
          sourcePortRange: '443'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'outbound'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          description: 'Deny All Inbound'
          protocol: '*'
          sourcePortRanges: [
            '8080'
            '5701'
          ]
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'outbound'
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          description: 'Deny All Inbound'
          protocol: '*'
          sourcePortRange: '80'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 130
          direction: 'outbound'
        }
      }
    ]
  }
}

output aksclusternsgid string = aksclusternsg.id
output aksmanagementnsgid string = aksmanagementnsg.id
output azurebastionnsgid string = azurebastionnsg.id

