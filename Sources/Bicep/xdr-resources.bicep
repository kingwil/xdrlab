targetScope = 'resourceGroup'

@description('Password for the Jump and Workstation VMs')
@secure()
param AdminPassword string = 'Pass@w0rd$$$'

@description('The defualt username for the administrator user')
param AdminUser string = 'LabAdmin'

@description('Virtual Machine Size')
param VMSize string = 'Standard_D2s_v3'
param id string = take(uniqueString('subscription'), 5)

var vm_dc1_nic_name = 'srv-dc1-nic'
var vm_srv1_nic_name = 'srv-app1-nic'
var vm_pc1_nic_name = 'pc-01-nic'
var vm_pc2_nic_name = 'pc-02-nic'

var vm_dc1_name = 'srv-dc1'
var vm_srv1_name = 'srv-app1'
var vm_pc1_name = 'pc-01'
var vm_pc2_name = 'pc-02'

var vnet_name = 'test-vnet'
var pip_name = 'bastion-pip'
var subnet_name = 'tier0-subnet'
var dc_ip = '10.0.2.100'
var srv1_ip = '10.0.2.101'
var bastion_name = 'xdr-bastion'

resource pip_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: pip_name
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
  }
}

resource subnet_resource 'Microsoft.Network/virtualNetworks/subnets@2020-04-01' = {
  name: '${vnet_resource.name}/${subnet_name}'
  dependsOn: [
    vnet_resource
  ]
  properties: {
    addressPrefix: '10.0.2.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vnet_resource 'Microsoft.Network/virtualNetworks@2020-04-01' = {
  name: vnet_name
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        dc_ip
        '168.63.129.16'
      ]
    }
  }
  dependsOn: []
}

resource subnet_bastion_resource 'Microsoft.Network/virtualNetworks/subnets@2020-04-01' = {
  name: '${vnet_resource.name}/AzureBastionSubnet'
  dependsOn: [
    vnet_resource
    subnet_resource
  ]
  properties: {
    addressPrefix: '10.0.0.0/27'
  }
}

resource bastion_resource 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: bastion_name
  dependsOn: [
    subnet_bastion_resource
  ]
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: subnet_bastion_resource.id
          }
          publicIPAddress: {
            id: pip_resource.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
        name: 'bastionIpConf'
      }
    ]
  }
}

resource nic_vm_dc1_resource 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: vm_dc1_nic_name
  location: resourceGroup().location
  dependsOn: [
    subnet_resource
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: dc_ip
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet_resource.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource nic_vm_srv1_resource 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: vm_srv1_nic_name
  location: resourceGroup().location
  dependsOn: [
    subnet_resource
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: srv1_ip
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet_resource.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource nic_vm_pc1_resource 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: vm_pc1_nic_name
  location: resourceGroup().location
  dependsOn: [
    subnet_resource
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet_resource.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource nic_vm_pc2_resource 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: vm_pc2_nic_name
  location: resourceGroup().location
  dependsOn: [
    subnet_resource
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet_resource.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource vm_dc1_resource 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vm_dc1_name
  location: resourceGroup().location
  dependsOn: [
    nic_vm_dc1_resource
  ]
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_dc1_name}_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vm_dc1_name
      adminUsername: AdminUser
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic_vm_dc1_resource.id
        }
      ]
    }
    licenseType: 'Windows_Server'
  }
}

resource vm_srv1_resource 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vm_srv1_name
  location: resourceGroup().location
  dependsOn: [
    nic_vm_srv1_resource
  ]
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_srv1_name}_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vm_srv1_name
      adminUsername: AdminUser
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic_vm_srv1_resource.id
        }
      ]
    }
    licenseType: 'Windows_Server'
  }
}

resource vm_pc1_resource 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vm_pc1_name
  location: resourceGroup().location
  dependsOn: [
    nic_vm_pc1_resource
  ]
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '20h2-ent-g2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_pc1_name}_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vm_pc1_name
      adminUsername: AdminUser
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic_vm_pc1_resource.id
        }
      ]
    }
    licenseType: 'Windows_Client'
  }
}

resource vm_pc2_resource 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vm_pc2_name
  location: resourceGroup().location
  dependsOn: [
    nic_vm_pc2_resource
  ]
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '20h2-ent-g2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_pc2_name}_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vm_pc2_name
      adminUsername: AdminUser
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic_vm_pc2_resource.id
        }
      ]
    }
    licenseType: 'Windows_Client'
  }
}

resource vm_dc1_dsc_extension_resource 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vm_dc1_resource.name}/Microsoft.Powershell.DSC'
  dependsOn: [
    vm_dc1_resource
  ]
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.83'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: 'https://github.com/kingwil/xdrlab/raw/main/Sources/DSC/config-adds.ps1.zip'
        script: 'config-adds.ps1'
        function: 'config-adds'
      }
    }
    protectedSettings: {
      configurationArguments: {
        Credential: {
          userName: AdminUser
          password: AdminPassword
        }
      }
    }
  }
}

resource vm_srv1_join_extension_resource 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = {
  name: '${vm_srv1_resource.name}/JoinDomain'
  dependsOn: [
    vm_dc1_dsc_extension_resource
  ]
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: 'contoso.com'
      User: 'CONTOSO\\${AdminUser}'
      Restart: true
      Options: 3
    }
    protectedSettings: {
      Password: AdminPassword
    }
  }
}

resource vm_pc1_join_extension_resource 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = {
  name: '${vm_pc1_resource.name}/JoinDomain'
  dependsOn: [
    vm_dc1_dsc_extension_resource
  ]
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: 'contoso.com'
      User: 'CONTOSO\\${AdminUser}'
      Restart: true
      Options: 3
    }
    protectedSettings: {
      Password: AdminPassword
    }
  }
}

resource vm_pc2_join_extension_resource 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = {
  name: '${vm_pc2_resource.name}/JoinDomain'
  dependsOn: [
    vm_dc1_dsc_extension_resource
  ]
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: 'contoso.com'
      User: 'CONTOSO\\${AdminUser}'
      Restart: true
      Options: 3
    }
    protectedSettings: {
      Password: AdminPassword
    }
  }
}

resource la_workspace_resource 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: 'xdr${id}'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource la_workspace_sentinel_resource 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  dependsOn: [
    la_workspace_resource
  ]
  location: resourceGroup().location
  name: 'SecurityInsights(${la_workspace_resource.name})'
  plan: {
    name: 'SecurityInsights'
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: la_workspace_resource.id
  }
}

resource la_workspace_sentinel_eventcollection_resource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  name: '${la_workspace_resource.name}/SecurityInsightsSecurityEventCollectionConfiguration'
  dependsOn: [
    la_workspace_sentinel_resource
  ]
  kind: 'SecurityInsightsSecurityEventCollectionConfiguration'
  properties: {
    tier: 'All'
    tierSetMethod: 'Custom'
  }
}

resource la_workspace_updates_resource 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  dependsOn: [
    la_workspace_resource
  ]
  location: resourceGroup().location
  name: 'Updates(${la_workspace_resource.name})'
  plan: {
    name: 'Updates'
    product: 'OMSGallery/Updates'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: la_workspace_resource.id
  }
}

resource la_workspace_changes_resource 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  dependsOn: [
    la_workspace_resource
  ]
  location: resourceGroup().location
  name: 'ChangeTracking(${la_workspace_resource.name})'
  plan: {
    name: 'ChangeTracking'
    product: 'OMSGallery/ChangeTracking'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: la_workspace_resource.id
  }
}

output la_workspace_resourceId string = la_workspace_resource.id
