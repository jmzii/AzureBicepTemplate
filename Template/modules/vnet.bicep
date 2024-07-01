// Parameters
param location string = resourceGroup().location

param addressSpace string = '10.0.0.0/16' // VNet address space

param vnetName string = 'vnetMain'

param bastionNsgName string = 'bastionNSG'

param bastionSubnetName string = 'AzureBastionSubnet'

param bastionSubnetPrefix string = '10.0.0.0/24' // Address range for Azure Bastion Subnet

param targetNsgName string = 'targetNSG'

param targetSubnetName string = 'TargetSubnet'

param targetSubnetPrefix string = '10.0.1.0/24' // Address range for Target Subnet

// Main VNet with bastion subnet and target subnet
resource vnetMain 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetPrefix
          networkSecurityGroup: {
            id: bastionNSG.id
          }
        }
      }
      {
        name: targetSubnetName
        properties: {
          addressPrefix: targetSubnetPrefix
          networkSecurityGroup: {
            id: targetNSG.id
          }
        }
      }
    ]
  }
}

// NSG for AzureBastionSubnet
resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: bastionNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          description: 'Allow HTTPS traffic to Azure bastion'
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionCommunicationInbound'
        properties: {
          description: 'Allow bastion components to communicate'
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '5701'
            '8080'
          ]
          direction: 'Inbound'
          priority: 110
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          description: 'Gateway manager communication with bastion'
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 120
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          description: 'Allow traffic to target subnet through SSH and RDP'
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          direction: 'Outbound'
          priority: 130
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionCommunicationOutbound'
        properties: {
          description: 'Allow bastion components to communicate'
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '5701'
            '8080'
          ]
          direction: 'Outbound'
          priority: 140
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          description: 'Allow connecting to endpoints for storing diagnostics logs etc'
          access: 'Allow'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
          direction: 'Outbound'
          priority: 150
          protocol: 'TCP'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

// NSG for Target Subnet
resource targetNSG 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: targetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          description: 'Allow traffic from AzureBastionSubnet through SSH and RDP'
          access: 'Allow'
          destinationAddressPrefix: bastionSubnetPrefix
          destinationPortRanges: [
            '22'
            '3389'
          ]
          direction: 'Inbound'
          priority: 100
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

output vnetMainId string = vnetMain.id
