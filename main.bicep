@description('Specifies the base name for all resources.')
param baseName string = 'freenow${substring(replace(guid(resourceGroup().id), '-', ''), 0, 4)}'

@description('Specifies the location to deploy to.')
param location string = resourceGroup().location

@description('Specifies the admin username of the PostgreSQL server.')
param postgresServerAdminLogin string = 'freenowadmin'

@description('Specifies the password of the PostgreSQL server administrator.')
@secure()
param postgresServerAdminPassword string

@description('Specifies the Kubernetes version.')
@allowed([
  '1.26.3'
  '1.26.0'
  '1.25.6'
  '1.25.5'
  '1.24.10'
  '1.24.9'
])
param kubernetesVersion string = '1.24.10'

@description('Specifies the number of agent nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('Specifies the VM size of agent nodes.')
param agentVMSize string = 'Standard_D2as_v5'

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    baseName: baseName
    location: location
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    baseName: baseName
    location: location
    postgresServerAdminLogin: postgresServerAdminLogin
    postgresServerAdminPassword: postgresServerAdminPassword
    postgresPrivateDnsZoneResourceId: network.outputs.postgresPrivateDnsZoneResourceId
    postgresSubnetResourceId: network.outputs.postgresSubnetResourceId
    postgresDatabase: 'demo'
    redisSubnetResourceId: network.outputs.redisSubnetResourceId
  }
}

module cluster 'modules/cluster.bicep' = {
  name: 'cluster'
  params: {
    baseName: baseName
    location: location
    clusterSubnetResourceId: network.outputs.clusterSubnetResourceId
    apiServerSubnetResourceId: network.outputs.apiServerSubnetResourceId
    kubernetesVersion: kubernetesVersion
    minCount: agentCount
    agentVMSize: agentVMSize
    enableKEDA: true
  }
}
