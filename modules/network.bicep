@description('Specifies the base name for all resources.')
param baseName string

@description('Specifies the location to deploy to.')
param location string

var resgpguid = substring(replace(guid(resourceGroup().id), '-', ''), 0, 4)
var vnetName = 'vnet-${location}-${resgpguid}'
var nsgAppGwName = 'nsg-appgw-${location}-${resgpguid}'
var nsgAksName = 'nsg-aks-${location}-${resgpguid}'
var nsgDatabaseName = 'nsg-database-${location}-${resgpguid}'
var nsgRedisName = 'nsg-redis-${location}-${resgpguid}'
var kubernetesSubnetName = 'snet-k8s'
var applicationGatewaySubnetName = 'snet-appgw'
var databaseSubnetName = 'snet-database'
var redisSubnetName = 'snet-redis'

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

output postgresPrivateDnsZoneResourceId string = privateDnsZonePostgres.id
output postgresSubnetResourceId string = vnet.properties.subnets[2].id
output redisSubnetResourceId string = vnet.properties.subnets[3].id

