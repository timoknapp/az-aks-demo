@description('Specifies the base name for all resources.')
param baseName string = 'freenow'

@description('Specifies the location to deploy to.')
param location string = resourceGroup().location

@description('Specifies the admin username of the PostgreSQL server.')
param postgresServerAdminLogin string = 'postgres'

@description('Specifies the password of the PostgreSQL server administrator.')
@secure()
param postgresServerAdminPassword string


module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    baseName: baseName
    location: location
  }
}

module database 'modules/database.bicep' = {
  name: 'database'
  params: {
    baseName: baseName
    location: location
    postgresServerAdminLogin: postgresServerAdminLogin
    postgresServerAdminPassword: postgresServerAdminPassword
    postgresPrivateDnsZoneResourceId: network.outputs.postgresPrivateDnsZoneResourceId
    postgresSubnetResourceId: network.outputs.postgresSubnetResourceId
    redisSubnetResourceId: network.outputs.redisSubnetResourceId
  }
}
