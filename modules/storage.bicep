@description('Specifies the base name for all resources.')
param baseName string

@description('Specifies a unique identifier to be added to resource names.')
param id string = '001'

@description('Specifies the location to deploy to.')
param location string

@description('Specifies the admin username of the PostgreSQL server.')
param postgresServerAdminLogin string = 'postgres'

@description('Specifies the password of the PostgreSQL server administrator.')
@secure()
@minLength(8)
param postgresServerAdminPassword string

@description('Specifies the resource ID of the Private DNS Zone for PostgreSQL.')
param postgresPrivateDnsZoneResourceId string

@description('Specifies the resource ID of the delegated subnet for PostgreSQL.')
param postgresSubnetResourceId string

@description('Specifies the resource ID of the delegated subnet for Redis.')
param redisSubnetResourceId string

@description('Specifies the availability zone for the PostgreSQL primary server.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZone string = '1'

resource postgresqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: '${baseName}${id}'
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
    administratorLogin: postgresServerAdminLogin
    administratorLoginPassword: postgresServerAdminPassword
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    availabilityZone: availabilityZone
    network: {
      delegatedSubnetResourceId: postgresSubnetResourceId
      privateDnsZoneArmResourceId: postgresPrivateDnsZoneResourceId
    }
  }
}

resource redisCache 'Microsoft.Cache/redis@2023-04-01' = {
  name: '${baseName}${id}'
  location: location
  properties: {
    sku: {
      name: 'Premium'
      family: 'P'
      capacity: 1
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    subnetId: redisSubnetResourceId
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${baseName}${id}'
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
