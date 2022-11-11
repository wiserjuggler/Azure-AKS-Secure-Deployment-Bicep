targetScope = 'resourceGroup'

// Parameters

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'Dev'
  'CAT'
  'Prod'
]) 
param environment string  //specify in the param file

@description('Specify the Portfolio')
param portfolio string  //specify in the param file

@description('Vnet CIDR Block for the AKS cluster')
param vnetCidrPrefix string  //specify in the param file

@description('CIDR Block for Firewall Subnet')
param AzureFirewallCidr string


// Role Assignment 

// module roleassignment 'roleassignment/roleassignment.bicep' = {
//   name: 'AKSSubnetRoleAssignment'
//   params: {
//     AksPrincipalId: aks.outputs.aksclusterid 
//     SubnetID: vnet.outputs.privateEndpointSubnetId
//   }
//   dependsOn: [
//     aks
//     vnet
//   ]
// }


// Create Disk Access

module diskaccess 'diskaccess/diskaccess.bicep' = {
  name: 'DiskAccess-Deployment'
  params: {
    location: location
    DiskAccessName: '${environment}-${portfolio}aks-DiskAccess'
  }
}

// ACR Registry creation

module acr './acr/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    location: location
    acrname: '${environment}${portfolio}aksacr'
  }
}

// Create Private DNS ZONE
module dnszoneacr './privateEnpoint/private-dns-zone.bicep' = {
  name: 'dnz-zone-Deployment-1'
  params: {
    privateDnsZoneName: 'privatelink.azurecr.io'
    virtualNetworkName: vnet.outputs.vnetname
    vnetId: vnet.outputs.vnetId
  }
}

module dnszonedisk './privateEnpoint/private-dns-zone.bicep' = {
  name: 'dnz-zone-Deployment-2'
  params: {
    privateDnsZoneName: 'privatelink.blob.core.windows.net'
    virtualNetworkName: vnet.outputs.vnetname
    vnetId: vnet.outputs.vnetId
  }
}

module dnszonekeyvault './privateEnpoint/private-dns-zone.bicep' = {
  name: 'dnz-zone-Deployment-3'
  params: {
    privateDnsZoneName: 'privatelink.vaultcore.azure.net'
    virtualNetworkName: vnet.outputs.vnetname
    vnetId: vnet.outputs.vnetId
  }
}


// Create Private Endpoint for the AKS Cluster


module acrprivateEndpoint './privateEnpoint/privateEndpoint.bicep' = {
  name: 'ACR-AKS-private-endpoint'
  params: {
    location: location
    privateEndpointName: '${environment}-${portfolio}-ACR-AKS-PrivateEndpoint'
    groupIds: [
      'registry'
    ]
    linkedServiceId: acr.outputs.acr
    privateEndpointSubnetId: vnet.outputs.privateEndpointSubnetId
    privateDnsZoneName: dnszoneacr.outputs.privateDnsZoneName
    DnsZoneConfigName: '${dnszoneacr.outputs.privateDnsZoneName}-config'
    DnsZoneId: dnszoneacr.outputs.privateDnsZoneId
  }
}

module diskprivateEndpoint './privateEnpoint/privateEndpoint.bicep' = {
  name: 'diskAccess-AKS-private-endpoint'
  params: {
    location: location
    privateEndpointName: '${environment}-${portfolio}-DiskAccess-AKS-PrivateEndpoint'
    groupIds: [
      'disks'
    ]
    linkedServiceId: diskaccess.outputs.DiskAccessId
    privateEndpointSubnetId: vnet.outputs.privateEndpointSubnetId
    privateDnsZoneName: dnszonedisk.outputs.privateDnsZoneName
    DnsZoneConfigName: '${dnszonedisk.outputs.privateDnsZoneName}-config'
    DnsZoneId: dnszonedisk.outputs.privateDnsZoneId
  }
}

module keyVaultprivateEndpoint './privateEnpoint/privateEndpoint.bicep' = {
  name: 'Keyvault-AKS-private-endpoint'
  params: {
    location: location
    privateEndpointName: '${environment}-${portfolio}-KeyVault-AKS-PrivateEndpoint'
    groupIds: [
      'vault'
    ]
    linkedServiceId: keyvault.outputs.KeyVaultId
    privateEndpointSubnetId: vnet.outputs.privateEndpointSubnetId
    privateDnsZoneName: dnszonekeyvault.outputs.privateDnsZoneName
    DnsZoneConfigName: '${dnszonekeyvault.outputs.privateDnsZoneName}-config'
    DnsZoneId: dnszonekeyvault.outputs.privateDnsZoneId
  }
}

// Create AKS Cluster
module aks 'aks/aks.bicep' ={
  name: 'AKS-Deploy'
  params: {
    location: location
    AksClusterName: '${environment}-${portfolio}-AKS-Cluster'
    diskEncryptionSetID: diskencryptionset.outputs.desId
    dnsPrefix: '${environment}-${portfolio}-AKS'
    LogAnalyticsWorkSpaceId: loganalyticsworkspace.outputs.LogAnalyticsWorkSpaceId
    vnetSubnetID: vnet.outputs.privateEndpointSubnetId
    nodeResourceGroup: '${environment}-${portfolio}-AKS-Management-RG'
  }
  dependsOn: [
    loganalyticsworkspace
  ]
}

// Module to create Log Analytics Workspace 
module loganalyticsworkspace 'loganalytics/loganalyticsworkspace.bicep' ={
  name: 'log-analytics-Deploymet'
  params: {
    location: location
    logAnalyticsWorkspaceName: '${environment}-${portfolio}-AKS-LogAnalytics'
  }
}

// Module to create Keyvault
module keyvault 'keyvault/keyvault.bicep' = {
  name: 'keyvault-deploy'
  params: {
    location: location
    keyVaultName: '${environment}-${portfolio}-AKS-keyVault'
    vnetName: '${environment}-${portfolio}-AKS-Vnet'
    privateEndpointSubnetName: '${environment}-${portfolio}-AKS-Cluster-Subnet'
  }
  dependsOn: [
    vnet
  ]
}

// module to create encryption key in Keyvault
module encryptionkey 'keyvault/keys.bicep' = {
  name: 'encryption-key-deploy'
  params: {
    keyName: '${environment}-${portfolio}-AKS-EncryptionKey'
    keySize: 4096
    keyVaultName: keyvault.outputs.keyVaultName
  }
  dependsOn:[
    keyvault
  ]
}

// create Disk encryption set
module diskencryptionset 'diskencyrptionset/diskencryptionset.bicep' = {
  name: 'DiskEncryptionSet-Deploy'
  params: {
    location:location
    DiskEncryptionSetName: '${environment}-${portfolio}-AKS-DiskEncryptionSet'
    KeyVaultId: keyvault.outputs.KeyVaultId
    keyUrl: encryptionkey.outputs.KeyUrl
  }
}

// Create Access Policy for KeyVault
var permissions = {
  keys: [
    'get'
    'wrapKey'
    'unwrapKey'
  ]
  secrets: [
    'get'
    'list'
  ]
}

// Module to add access on disk encryption set
module accesspolicy 'keyvault/access-policy.bicep' = {
  name: 'access-policy-deploy'
  params: {
    keyVaultName: keyvault.outputs.keyVaultName
    permissions: permissions
    principalId: diskencryptionset.outputs.principalId
  }
}

// Module to create NSG
module nsg './nsg/nsg.bicep' = {
  name: 'nsg-deploy'
  params: {
    location: location
    AKSClusterSubnetName: '${environment}-${portfolio}-AKS-Cluster-Subnet'
    AKSManagementSubnetName: '${environment}-${portfolio}-AKS-Management-Subnet'
    AzureBastionSubnetName: '${environment}-${portfolio}-AzureBastion-Subnet'
  }
}

// module to create Route Tables

module Aksclusterroutetable './routetable/routetable.bicep' = {
  name: 'AksCluster-routetable-deploy'
  params: {
    location: location
    RouteTableName: '${environment}-${portfolio}-AKS-Cluster-RouteTable'
    AzureFirewallCidr: AzureFirewallCidr
  }
}

module AksManagementroutetable './routetable/routetable.bicep' = {
  name: 'AksManagement-routetable-deploy'
  params: {
    location: location
    RouteTableName: '${environment}-${portfolio}-AKS-Management-RouteTable'
    AzureFirewallCidr: AzureFirewallCidr
  }
}

// Module to create VNET
module vnet './vnet/vnet.bicep' ={
  name: 'vnet-deploy'
  params: {
    location: location
    AKSClusterSubnetName: '${environment}-${portfolio}-AKS-Cluster-Subnet'
    AKSManagementSubnetName: '${environment}-${portfolio}-AKS-Management-Subnet'
    AzureBastionSubnetName: '${environment}-${portfolio}-AzureBastion-Subnet'
    AKSClusternsg: nsg.outputs.aksclusternsgid
    AKSManagementnsg: nsg.outputs.aksmanagementnsgid
    AzureBastionnsg: nsg.outputs.azurebastionnsgid
    vnetName: '${environment}-${portfolio}-AKS-Vnet' 
    vnetCidrPrefix: vnetCidrPrefix
    AKSClusterroutetableid: Aksclusterroutetable.outputs.routetableid
    AKSManagementroutetableid: AksManagementroutetable.outputs.routetableid
  }
  dependsOn: [
    nsg
  ]
}
