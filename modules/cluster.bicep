@description('Specifies the base name for all resources.')
param baseName string

@description('Specifies the location to deploy to.')
param location string

@description('Specifies the Kubernetes version.')
@allowed([
  '1.26.3'
  '1.26.0'
  '1.25.6'
  '1.25.5'
  '1.24.10'
  '1.24.9'
])
param kubernetesVersion string

@description('Specifies the resource ID of the delegated subnet for the cluster.')
param clusterSubnetResourceId string

@description('Specifies the resource ID of the delegated subnet for the API server.')
param apiServerSubnetResourceId string

@description('Specifies the number of agent nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int

@description('Specifies the VM size of agent nodes.')
param agentVMSize string 

@description('Specifies whether to enable CSIv2 drivers (preview).')
param enableCSIDiskDriverV2 bool = false

@description('Specifies whether to enable KEDA (preview).')
param enableKEDA bool = false

var clusterName = '${baseName}-cluster'

var enableApiServerVnetIntegration = false

resource aksIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  location: location
  name: clusterName
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-04-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksIdentity.id}': {}
    }
  }  
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    nodeResourceGroup: '${resourceGroup().name}-deps'
    dnsPrefix: baseName
    
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
        name: 'nodepool1'
        count: agentCount
        minCount: agentCount
        maxCount: agentCount * 2
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
        osDiskType: 'Managed'
        vnetSubnetID: clusterSubnetResourceId
        enableAutoScaling: true
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
    ]

    apiServerAccessProfile: {
      enableVnetIntegration: enableApiServerVnetIntegration
      subnetId: enableApiServerVnetIntegration ? apiServerSubnetResourceId : ''
    }
      
    networkProfile: {
      networkPolicy: 'azure'
      networkPlugin: 'azure'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
    }

    oidcIssuerProfile: {
      enabled: true
    }

    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }

    storageProfile: enableCSIDiskDriverV2 ? {
      diskCSIDriver: {
        enabled: true
        version: 'v2'
      }
    } : null

    workloadAutoScalerProfile: enableKEDA ? {
      keda: {
        enabled: true
      }
    } : null
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: baseName
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

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${baseName}-logs'
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

@description('This is the built-in ACRPull role.')
resource acrPull 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  scope: subscription()
}

@description('This is the built-in NetWork Contributor role.')
resource networkContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  scope: subscription()
}

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksCluster.id, acrPull.id)
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPull.id
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

resource networkContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksCluster.id, networkContributor.id) 
  scope: resourceGroup()
  properties: {
    roleDefinitionId: networkContributor.id
    principalId: aksIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
