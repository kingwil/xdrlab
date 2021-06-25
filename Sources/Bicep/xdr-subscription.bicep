targetScope = 'subscription'

var rgName = 'XDR-LAB'
var location = 'westeurope'

resource rg_resource 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

resource asc_pricings_vm_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'VirtualMachines'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_sql_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServers'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_app_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'AppServices'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_stor_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_sqlvm_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServerVirtualMachines'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_kube_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'KubernetesService'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_acr_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'ContainerRegistry'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_kv_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'KeyVaults'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_dns_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Dns'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_arm_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Arm'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_pricings_osrd_resource 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'OpenSourceRelationalDatabases'
  properties: {
    pricingTier: 'Standard'
  }
}

resource asc_workspace_resource 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = {
  dependsOn: [
    deploy_module
  ]
  name: 'default'
  properties: {
    scope: subscription().id
    workspaceId: deploy_module.outputs.la_workspace_resourceId
  }
}

module deploy_module './xdr-resources.bicep' = {
  name: 'xdr-resource'
  scope: rg_resource 
}

