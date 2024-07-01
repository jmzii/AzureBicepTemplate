// Parameters
param location string = resourceGroup().location

param bastionPublicIPName string = 'bastionPublicIP'

param bastionHostName string

param bastionSubnetName string

param vnetName string

// Existing main VNet
resource vnetMain 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(subscription().subscriptionId, resourceGroup().name)
}
output vnetId string = vnetMain.id

// Existing bastion subnet
resource subnetBastion 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: bastionSubnetName
  parent: vnetMain
}

var bastionSubnetId = subnetBastion.id
output bastionSubnetId string = bastionSubnetId

// Public IP for bastion
resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: bastionPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Bastion host
resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: bastionPublicIP.id
          }
        }
      }
    ]
  }
}
