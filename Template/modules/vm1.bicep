// Parameters
param location string = resourceGroup().location

param niName string = 'networkInterfaceVM1'

param vmName string = 'vm1'

param vmSize string = 'Standard_B2s'

param publisher string = 'MicrosoftWindowsServer'

param offer string = 'WindowsServer'

param sku string = '2016-Datacenter'

param version string = 'latest'

param vnetId string

param targetSubnetName string

param adminUsername string = 'adminuser'

@secure()
param adminPassword string

// Variable for target subnet
var targetSubnetRef = '${vnetId}/subnets/${targetSubnetName}'

// Network Interface for VM 1
resource networkInterface1 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: niName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: targetSubnetRef
          }
        }
      }
    ]
  }
}

// VM 1
resource vm1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: version
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
        }
      ]
    }
  }
}
