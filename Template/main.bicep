targetScope = 'resourceGroup'

param location string = resourceGroup().location

param targetSubnetName string

@secure()
param adminPasswordVM1 string

@secure()
param adminPasswordVM2 string

// Modules
module vnet './modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    targetSubnetName: targetSubnetName
  }
}

module bastion './modules/bastion.bicep' = {
  name: 'bastionDeployment'
  params: {
    location: location
    bastionHostName: 'bastionHost'
    bastionSubnetName: 'AzureBastionSubnet'
    vnetName: 'vnetMain'
  }
  dependsOn: [
    vnet
  ]
}

module vm1 './modules/vm1.bicep' = {
  name: 'vm1Deployment'
  params: {
    adminPassword: adminPasswordVM1
    location: location
    vnetId: vnet.outputs.vnetMainId
    targetSubnetName: 'TargetSubnet'
  }
  dependsOn: [
    vnet
  ]
}

module vm2 './modules/vm2.bicep' = {
  name: 'vm2Deployment'
  params: {
    adminPassword: adminPasswordVM2
    location: location
    vnetId: vnet.outputs.vnetMainId
    targetSubnetName: 'TargetSubnet'
  }
  dependsOn: [
    vnet
  ]
}
