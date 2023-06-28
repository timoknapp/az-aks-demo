@description('Specifies the base name for all resources.')
param baseName string

@description('Specifies the location to deploy to.')
param location string

@description('The sku of the Application Gateway. Default: WAF_v2 (Detection mode). In order to further customize WAF, use azure portal or cli.')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param applicationGatewaySku string = 'WAF_v2'

@description('IP Address of the Ingress Controller within AKS used as a backend pool in Application Gateway.')
param aksIngressServiceIP string = '10.1.127.127'

@description('VNET IP address prefix.')
param virtualNetworkAddressPrefix string = '10.1.0.0/16'

@description('AKS subnet IP address prefix.')
param aksSubnetAddressPrefix string = '10.1.0.0/17'

@description('App Gateway subnet IP address prefix.')
param applicationGatewaySubnetAddressPrefix string = '10.1.252.0/23'

@description('Database subnet IP address prefix.')
param databaseSubnetAddressPrefix string = '10.1.224.0/20'

@description('Redis subnet IP address prefix.')
param redisSubnetAddressPrefix string = '10.1.254.0/24'

@description('AKS API Server subnet IP address prefix.')
param aksApiServerSubnetAddressPrefix string = '10.1.255.0/24'

var applicationGatewayName = '${baseName}-appgw'
var applicationGatewayPublicIpName = '${baseName}-pip-appgw'
var webApplicationFirewallConfiguration = {
  enabled: 'true'
  firewallMode: 'Detection'
}
var vnetName = '${baseName}-vnet'
var kubernetesSubnetName = 'k8s-subnet'
var aksApiServerSubnetName = 'k8s-apiserver-subnet'
var applicationGatewaySubnetName = 'appgw-subnet'
var databaseSubnetName = 'postgres-subnet'
var redisSubnetName = 'redis-subnet'

resource networkSecurityGroupAppGw 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}-appgw-nsg'
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
  name: '${baseName}-k8s-nsg'
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

resource networkSecurityGroupAksApiServer 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}-k8s-apiserver-nsg'
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
    ]
  }
}

resource networkSecurityGroupDatabase 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}-postgres-nsg'
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
  name: '${baseName}-redis-nsg'
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
        name: aksApiServerSubnetName
        properties: {
          networkSecurityGroup: {
            id: networkSecurityGroupAksApiServer.id
          }
          addressPrefix: aksApiServerSubnetAddressPrefix
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

resource privateDnsZonePostgres 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${baseName}.postgres.database.azure.com'
  location: 'global'
}

resource privateDnsZoneVnetLinkPostgres 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'vnetlink-dnszone-postgres'
  parent: privateDnsZonePostgres
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName)
    }
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
            id: applicationGatewayPublicIp.id
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

output postgresPrivateDnsZoneResourceId string = privateDnsZonePostgres.id
output clusterSubnetResourceId string = vnet.properties.subnets[0].id
output postgresSubnetResourceId string = vnet.properties.subnets[2].id
output redisSubnetResourceId string = vnet.properties.subnets[3].id

