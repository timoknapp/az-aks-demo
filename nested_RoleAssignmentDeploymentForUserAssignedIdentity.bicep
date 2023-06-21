param reference_variables_identityId_2015_08_31_PREVIEW_principalId object
param variables_applicationGatewayName string
param variables_contributorRole string
param variables_applicationGatewayId string
param variables_readerRole string

resource variables_applicationGatewayName_Microsoft_Authorization_id_identityappgwaccess 'Microsoft.Network/applicationgateways/providers/roleAssignments@2017-05-01' = {
  name: '${variables_applicationGatewayName}/Microsoft.Authorization/${guid(resourceGroup().id, 'identityappgwaccess')}'
  properties: {
    roleDefinitionId: variables_contributorRole
    principalId: reference_variables_identityId_2015_08_31_PREVIEW_principalId.principalId
    scope: variables_applicationGatewayId
  }
}

resource id_identityrgaccess 'Microsoft.Authorization/roleAssignments@2017-05-01' = {
  name: guid(resourceGroup().id, 'identityrgaccess')
  properties: {
    roleDefinitionId: variables_readerRole
    principalId: reference_variables_identityId_2015_08_31_PREVIEW_principalId.principalId
    scope: resourceGroup().id
  }
}
