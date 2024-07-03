targetScope = 'resourceGroup'

param location string = resourceGroup().location

param targetSubnetName string = 'TargetSubnet'

param bastionHostName string = 'bastionHost'

param bastionSubnetName string = 'AzureBastionSubnet'

param vnetName string = 'vnetMain'

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
    bastionHostName: bastionHostName
    bastionSubnetName: bastionSubnetName
    vnetName: vnetName
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
    targetSubnetName: targetSubnetName
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
    targetSubnetName: targetSubnetName
  }
  dependsOn: [
    vnet
  ]
}
