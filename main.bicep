@description('appId of the service principal. Used by AKS to manage AKS related resources on Azure like vms, subnets.')
param aksServicePrincipalAppId string

@description('password for the service principal. Used by AKS to manage Azure.')
@secure()
param aksServicePrincipalClientSecret string

@description('objectId of the service principal.')
param aksServicePrincipalObjectId string

@description('VNET IP address prefix.')
param virtualNetworkAddressPrefix string = '10.0.0.0/8'

@description('AKS subnet IP address prefix.')
param aksSubnetAddressPrefix string = '10.254.0.0/16'

@description('App Gateway subnet IP address prefix.')
param applicationGatewaySubnetAddressPrefix string = '10.255.252.0/23'

@description('Database subnet IP address prefix.')
param databaseSubnetAddressPrefix string = '10.255.224.0/20'

@description('Redis subnet IP address prefix.')
param redisSubnetAddressPrefix string = '10.255.254.0/24'

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param aksDnsPrefix string = 'aks'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 30 to 1023.')
@minValue(30)
@maxValue(1023)
param aksAgentOsDiskSizeGB int = 40

@description('The number of agent nodes for the cluster.')
@minValue(1)
@maxValue(50)
param aksAgentCount int = 3

@description('The size of the Virtual Machine.')
@allowed([
  'Standard_A0'
  'Standard_A1'
  'Standard_A10'
  'Standard_A11'
  'Standard_A1_v2'
  'Standard_A2'
  'Standard_A2_v2'
  'Standard_A2m_v2'
  'Standard_A3'
  'Standard_A4'
  'Standard_A4_v2'
  'Standard_A4m_v2'
  'Standard_A5'
  'Standard_A6'
  'Standard_A7'
  'Standard_A8'
  'Standard_A8_v2'
  'Standard_A8m_v2'
  'Standard_A9'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B8ms'
  'Standard_D1'
  'Standard_D11'
  'Standard_D11_v2'
  'Standard_D11_v2_Promo'
  'Standard_D12'
  'Standard_D12_v2'
  'Standard_D12_v2_Promo'
  'Standard_D13'
  'Standard_D13_v2'
  'Standard_D13_v2_Promo'
  'Standard_D14'
  'Standard_D14_v2'
  'Standard_D14_v2_Promo'
  'Standard_D15_v2'
  'Standard_D16_v3'
  'Standard_D16s_v3'
  'Standard_D1_v2'
  'Standard_D2'
  'Standard_D2_v2'
  'Standard_D2_v2_Promo'
  'Standard_D2_v3'
  'Standard_D2s_v3'
  'Standard_D3'
  'Standard_D32_v3'
  'Standard_D32s_v3'
  'Standard_D3_v2'
  'Standard_D3_v2_Promo'
  'Standard_D4'
  'Standard_D4_v2'
  'Standard_D4_v2_Promo'
  'Standard_D4_v3'
  'Standard_D4s_v3'
  'Standard_D5_v2'
  'Standard_D5_v2_Promo'
  'Standard_D64_v3'
  'Standard_D64s_v3'
  'Standard_D8_v3'
  'Standard_D8s_v3'
  'Standard_DS1'
  'Standard_DS11'
  'Standard_DS11-1_v2'
  'Standard_DS11_v2'
  'Standard_DS11_v2_Promo'
  'Standard_DS12'
  'Standard_DS12-1_v2'
  'Standard_DS12-2_v2'
  'Standard_DS12_v2'
  'Standard_DS12_v2_Promo'
  'Standard_DS13'
  'Standard_DS13-2_v2'
  'Standard_DS13-4_v2'
  'Standard_DS13_v2'
  'Standard_DS13_v2_Promo'
  'Standard_DS14'
  'Standard_DS14-4_v2'
  'Standard_DS14-8_v2'
  'Standard_DS14_v2'
  'Standard_DS14_v2_Promo'
  'Standard_DS15_v2'
  'Standard_DS1_v2'
  'Standard_DS2'
  'Standard_DS2_v2'
  'Standard_DS2_v2_Promo'
  'Standard_DS3'
  'Standard_DS3_v2'
  'Standard_DS3_v2_Promo'
  'Standard_DS4'
  'Standard_DS4_v2'
  'Standard_DS4_v2_Promo'
  'Standard_DS5_v2'
  'Standard_DS5_v2_Promo'
  'Standard_E16-4s_v3'
  'Standard_E16-8s_v3'
  'Standard_E16_v3'
  'Standard_E16s_v3'
  'Standard_E2_v3'
  'Standard_E2s_v3'
  'Standard_E32-16s_v3'
  'Standard_E32-8s_v3'
  'Standard_E32_v3'
  'Standard_E32s_v3'
  'Standard_E4-2s_v3'
  'Standard_E4_v3'
  'Standard_E4s_v3'
  'Standard_E64-16s_v3'
  'Standard_E64-32s_v3'
  'Standard_E64_v3'
  'Standard_E64i_v3'
  'Standard_E64is_v3'
  'Standard_E64s_v3'
  'Standard_E8-2s_v3'
  'Standard_E8-4s_v3'
  'Standard_E8_v3'
  'Standard_E8s_v3'
  'Standard_F1'
  'Standard_F16'
  'Standard_F16s'
  'Standard_F16s_v2'
  'Standard_F1s'
  'Standard_F2'
  'Standard_F2s'
  'Standard_F2s_v2'
  'Standard_F32s_v2'
  'Standard_F4'
  'Standard_F4s'
  'Standard_F4s_v2'
  'Standard_F64s_v2'
  'Standard_F72s_v2'
  'Standard_F8'
  'Standard_F8s'
  'Standard_F8s_v2'
  'Standard_G1'
  'Standard_G2'
  'Standard_G3'
  'Standard_G4'
  'Standard_G5'
  'Standard_GS1'
  'Standard_GS2'
  'Standard_GS3'
  'Standard_GS4'
  'Standard_GS4-4'
  'Standard_GS4-8'
  'Standard_GS5'
  'Standard_GS5-16'
  'Standard_GS5-8'
  'Standard_H16'
  'Standard_H16m'
  'Standard_H16mr'
  'Standard_H16r'
  'Standard_H8'
  'Standard_H8m'
  'Standard_L16s'
  'Standard_L16s_v2'
  'Standard_L32s'
  'Standard_L4s'
  'Standard_L8s'
  'Standard_L8s_v2'
  'Standard_M128'
  'Standard_M128-32ms'
  'Standard_M128-64ms'
  'Standard_M128m'
  'Standard_M128ms'
  'Standard_M128s'
  'Standard_M16-4ms'
  'Standard_M16-8ms'
  'Standard_M16ms'
  'Standard_M32-16ms'
  'Standard_M32-8ms'
  'Standard_M32ls'
  'Standard_M32ms'
  'Standard_M32ts'
  'Standard_M64'
  'Standard_M64-16ms'
  'Standard_M64-32ms'
  'Standard_M64ls'
  'Standard_M64m'
  'Standard_M64ms'
  'Standard_M64s'
  'Standard_M8-2ms'
  'Standard_M8-4ms'
  'Standard_M8ms'
  'Standard_NC12'
  'Standard_NC12s_v2'
  'Standard_NC12s_v3'
  'Standard_NC24'
  'Standard_NC24r'
  'Standard_NC24rs_v2'
  'Standard_NC24rs_v3'
  'Standard_NC24s_v2'
  'Standard_NC24s_v3'
  'Standard_NC6'
  'Standard_NC6s_v2'
  'Standard_NC6s_v3'
  'Standard_ND12s'
  'Standard_ND24rs'
  'Standard_ND24s'
  'Standard_ND6s'
  'Standard_NV12'
  'Standard_NV24'
  'Standard_NV6'
])
param aksAgentVMSize string = 'Standard_D3_v2'

@description('The version of Kubernetes.')
param kubernetesVersion string = '1.24.10'

@description('A CIDR notation IP range from which to assign service cluster IPs.')
param aksServiceCIDR string = '10.252.0.0/15'

@description('Containers DNS server IP address.')
param aksDnsServiceIP string = '10.252.0.10'

@description('IP Address of the Ingress Controller within AKS used as a backend pool in Application Gateway.')
param aksIngressServiceIP string = '10.252.0.20'

@description('A CIDR notation IP for Docker bridge.')
param aksDockerBridgeCIDR string = '172.17.0.1/16'

@description('Enable RBAC on the AKS cluster.')
param aksEnableRBAC bool = false

@description('The sku of the Application Gateway. Default: WAF_v2 (Detection mode). In order to further customize WAF, use azure portal or cli.')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param applicationGatewaySku string = 'WAF_v2'

@description('The Admin username of the PostgreSQL server.')
param postgresqlServerAdminLogin string = 'postgres'

@description('The password of the PostgreSQL server administrator.')
@secure()
param postgresqlServerAdminPassword string

param location string = resourceGroup().location

var resgpguid = substring(replace(guid(resourceGroup().id), '-', ''), 0, 4)
var vnetName = 'vnet-${location}-${resgpguid}'
var nsgAppGwName = 'nsg-appgw-${location}-${resgpguid}'
var nsgAksName = 'nsg-aks-${location}-${resgpguid}'
var nsgDatabaseName = 'nsg-database-${location}-${resgpguid}'
var nsgRedisName = 'nsg-redis-${location}-${resgpguid}'
var applicationGatewayName = 'appgw-${location}-${resgpguid}'
var identityName = 'appgw-identity-${resgpguid}'
var applicationGatewayPublicIpName = 'pip-appgw-${location}-${resgpguid}'
var kubernetesSubnetName = 'snet-k8s'
var applicationGatewaySubnetName = 'snet-appgw'
var databaseSubnetName = 'snet-database'
var redisSubnetName = 'snet-redis'
var aksClusterName = 'aks-${location}-${resgpguid}'
var redisCacheName = 'redis-${location}-${resgpguid}'
var postgresqlServerName = 'psql-${location}-${resgpguid}'
var storageAccountName = 'storage${resgpguid}'
var containerRegistryName = 'acr${location}${resgpguid}'
var logAnalyticsWorkspaceName = 'law-${location}-${resgpguid}'
var applicationGatewayPublicIpId = applicationGatewayPublicIp.id
var applicationGatewayId = applicationGateway.id
var kubernetesSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, kubernetesSubnetName)
var identityId = resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', identityName)
var aksClusterId = resourceId('Microsoft.ContainerService/managedClusters', aksClusterName)
var networkContributorRole = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
var contributorRole = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var managedIdentityOperatorRole = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830'
var readerRole = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
var webApplicationFirewallConfiguration = {
  enabled: 'true'
  firewallMode: 'Detection'
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2015-08-31-PREVIEW' = {
  name: identityName
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2018-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: kubernetesSubnetName
        properties: {
          networkSecurityGroup: {
            id: networkSecurityGroupAks.id
          }
          addressPrefix: aksSubnetAddressPrefix
        }
      }
      {
        name: applicationGatewaySubnetName
        properties: {
          networkSecurityGroup: {
            id: networkSecurityGroupAppGw.id
          }
          addressPrefix: applicationGatewaySubnetAddressPrefix
        }
      }
      {
        name: databaseSubnetName
        properties: {
          networkSecurityGroup: {
            id: networkSecurityGroupDatabase.id
          }
          addressPrefix: databaseSubnetAddressPrefix
          delegations: [
            {
              name: 'Microsoft.DBforPostgreSQL/flexibleServers'
              properties: {
                serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
              }
            }
          ]
        }
      }
      {
        name: redisSubnetName
        properties: {
          networkSecurityGroup: {
            id: networkSecurityGroupRedis.id
          }
          addressPrefix: redisSubnetAddressPrefix
        }
      }
    ]
  }
}

resource networkSecurityGroupAppGw 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgAppGwName
  location: location
  properties: {
    securityRules: [
      {
        name: 'GatewayManager'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRange: '65200-65535'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 1000
          protocol: '*'
          sourceAddressPrefix: 'GatewayManager'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
      }
      {
        name: 'AllowAnyHTTPInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRange: '80'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 1001
          protocol: 'TCP'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
      }
    ]
  }
}

resource networkSecurityGroupAks 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgAksName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnyHTTPSInbound'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAnyHTTPInbound'
        properties: {
          priority: 1001
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '80'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAnyHTTPNonStandardInbound'
        properties: {
          priority: 1011
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '8000-8999'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource networkSecurityGroupDatabase 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgDatabaseName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnyDatabaseInbound'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '5432'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource networkSecurityGroupRedis 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgRedisName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnyRedisInbound'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '6379'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource applicationGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2018-08-01' = {
  name: applicationGatewayPublicIpName
  location: location

  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2018-08-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: applicationGatewaySku
      tier: applicationGatewaySku
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, applicationGatewaySubnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIpId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'httpPort'
        properties: {
          port: 80
        }
      }
      {
        name: 'httpsPort'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'aksIngressControllerPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: aksIngressServiceIP
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          protocol: 'Http'
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'httpPort')
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
          }
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'setting'
        properties: {
          port: 80
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'aksIngressControllerPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'setting')
          }
        }
      }
    ]
    webApplicationFirewallConfiguration: ((applicationGatewaySku == 'WAF_v2') ? webApplicationFirewallConfiguration : null)
  }
}

module RoleAssignmentDeploymentForKubenetesSp './nested_RoleAssignmentDeploymentForKubenetesSp.bicep' = {
  name: 'RoleAssignmentDeploymentForKubenetesSp'
  scope: resourceGroup(subscription().subscriptionId, resourceGroup().name)
  params: {
    variables_vnetName: vnetName
    variables_kubernetesSubnetName: kubernetesSubnetName
    variables_networkContributorRole: networkContributorRole
    variables_kubernetesSubnetId: kubernetesSubnetId
    variables_identityName: identityName
    variables_managedIdentityOperatorRole: managedIdentityOperatorRole
    variables_identityId: identityId
    aksServicePrincipalObjectId: aksServicePrincipalObjectId
  }
  dependsOn: [
    vnet
  ]
}

module RoleAssignmentDeploymentForUserAssignedIdentity './nested_RoleAssignmentDeploymentForUserAssignedIdentity.bicep' = {
  name: 'RoleAssignmentDeploymentForUserAssignedIdentity'
  scope: resourceGroup(subscription().subscriptionId, resourceGroup().name)
  params: {
    reference_variables_identityId_2015_08_31_PREVIEW_principalId: reference(identityId, '2015-08-31-PREVIEW')
    variables_applicationGatewayName: applicationGatewayName
    variables_contributorRole: contributorRole
    variables_applicationGatewayId: applicationGatewayId
    variables_readerRole: readerRole
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-03-02-preview' = {
  name: aksClusterName
  location: location
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: aksEnableRBAC
    nodeResourceGroup: '${resourceGroup().name}-deps'
    dnsPrefix: aksDnsPrefix
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }
      azurepolicy: {
        enabled: true
        config: {
          version: 'v2'
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'nodepool'
        osDiskSizeGB: aksAgentOsDiskSizeGB
        count: aksAgentCount
        minCount: aksAgentCount
        maxCount: aksAgentCount * 2
        vmSize: aksAgentVMSize
        osType: 'Linux'
        mode: 'System'
        osDiskType: 'Managed'
        vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, kubernetesSubnetName)
        enableAutoScaling: true
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
    servicePrincipalProfile: {
      clientId: aksServicePrincipalAppId
      secret: aksServicePrincipalClientSecret
    }
    networkProfile: {
      networkPlugin: 'azure'
      serviceCidr: aksServiceCIDR
      dnsServiceIP: aksDnsServiceIP
      dockerBridgeCidr: aksDockerBridgeCIDR
    }
  }
  dependsOn: [

    RoleAssignmentDeploymentForKubenetesSp
  ]
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    networkRuleSet: {
      defaultAction: 'Deny'
    }
  }
}

@description('This is the built-in ACRPull role.')
resource acrPull 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  scope: subscription()
}

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: 'acr-assignment-${resgpguid}'
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPull.id
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

resource privateDnsZonePostgres 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'freenow.postgres.database.azure.com'
  location: 'global'
}

resource privateDnsZoneVnetLinkPostgres 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'vnetlink-dnszone-postgres'
  parent: privateDnsZonePostgres
  location: location
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName)
    }
  }
}

resource postgresqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: postgresqlServerName
  location: location
  sku: {
    name: 'Standard_B2s'
    tier: 'Burstable'
  }
  properties: {
    storage: {
      storageSizeGB: 32
    }
    version: '13'
    administratorLogin: postgresqlServerAdminLogin
    administratorLoginPassword: postgresqlServerAdminPassword
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    availabilityZone: '1'
    network: {
      delegatedSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, databaseSubnetName)
      privateDnsZoneArmResourceId: privateDnsZonePostgres.id
    }
  }
}

resource redisCache 'Microsoft.Cache/redis@2023-04-01' = {
  name: redisCacheName
  location: location
  properties: {
    sku: {
      name: 'Premium'
      family: 'P'
      capacity: 1
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, redisSubnetName)
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

output subscriptionId string = subscription().subscriptionId
output resourceGroupName string = resourceGroup().name
output applicationGatewayName string = applicationGatewayName
output identityResourceId string = identityId
output identityClientId string = reference(identityId, '2015-08-31-PREVIEW').clientId
output aksApiServerAddress string = reference(aksClusterId, '2018-03-31').fqdn
output aksClusterName string = aksClusterName
