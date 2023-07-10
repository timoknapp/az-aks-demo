@description('Specifies the node pool\'s name.')
param nodePoolName string

@description('Specifies the cluster\'s name.')
param clusterName string

@description('Specifies the node pool\'s mode.')
@allowed([
  'System'
  'User'
])
param mode string = 'System'

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

@description('Specifies the minimum number of agent nodes for the cluster.')
@minValue(1)
@maxValue(50)
param minCount int = 3

@description('Specifies the maximum number of agent nodes for the cluster.')
@minValue(1)
@maxValue(50)
param maxCount int = 50

@description('Specifies the VM size of agent nodes.')
param agentVMSize string = 'Standard_D4ds_v4'

resource cluster 'Microsoft.ContainerService/managedClusters@2023-04-02-preview' existing = {
  name: clusterName
}

resource nodepool 'Microsoft.ContainerService/managedClusters/agentPools@2023-04-02-preview' = {
  name: nodePoolName
  parent: cluster
  properties: {
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    count: minCount
    enableAutoScaling: true
    maxCount: maxCount
    maxPods: 30
    minCount: minCount
    mode: mode
    orchestratorVersion: kubernetesVersion
    osType: 'Linux'
    osDiskType: 'Managed'
    vmSize: agentVMSize
    vnetSubnetID: cluster.properties.agentPoolProfiles[0].vnetSubnetID
  }
}
