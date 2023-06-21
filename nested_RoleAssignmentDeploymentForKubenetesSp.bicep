param variables_vnetName string
param variables_kubernetesSubnetName string
param variables_networkContributorRole string
param variables_kubernetesSubnetId string
param variables_identityName string
param variables_managedIdentityOperatorRole string
param variables_identityId string

@description('objectId of the service principal.')
param aksServicePrincipalObjectId string

resource variables_vnetName_variables_kubernetesSubnetName_Microsoft_Authorization_id_aksvnetaccess 'Microsoft.Network/virtualNetworks/subnets/providers/roleAssignments@2017-05-01' = {
  name: '${variables_vnetName}/${variables_kubernetesSubnetName}/Microsoft.Authorization/${guid(resourceGroup().id, 'aksvnetaccess')}'
  properties: {
    roleDefinitionId: variables_networkContributorRole
    principalId: aksServicePrincipalObjectId
    scope: variables_kubernetesSubnetId
  }
}

resource variables_identityName_Microsoft_Authorization_id_aksidentityaccess 'Microsoft.ManagedIdentity/userAssignedIdentities/providers/roleAssignments@2017-05-01' = {
  name: '${variables_identityName}/Microsoft.Authorization/${guid(resourceGroup().id, 'aksidentityaccess')}'
  properties: {
    roleDefinitionId: variables_managedIdentityOperatorRole
    principalId: aksServicePrincipalObjectId
    scope: variables_identityId
    principalType: 'ServicePrincipal'
  }
}
