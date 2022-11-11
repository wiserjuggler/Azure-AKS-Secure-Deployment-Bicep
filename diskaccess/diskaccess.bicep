param DiskAccessName string
param location string = resourceGroup().location

resource diskaccess 'Microsoft.Compute/diskAccesses@2022-07-02' = {
  name: DiskAccessName
  location: location
}

output DiskAccessId string = diskaccess.id
