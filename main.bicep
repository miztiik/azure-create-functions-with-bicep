targetScope = 'subscription'

// Parameters
param deploymentParams object
param appConfigParams object
param storageAccountParams object
param storageQueueParams object
param logAnalyticsWorkspaceParams object
param dceParams object
param funcParams object

param brandTags object


var location = deploymentParams.location
var rgName = '${deploymentParams.enterprise_name}_${deploymentParams.enterprise_name_suffix}_${deploymentParams.global_uniqueness}'

param dateNow string = utcNow('yyyy-MM-dd-hh-mm')

param tags object = union(brandTags, {last_deployed:dateNow})

// Create Resource Group
module r_rg 'modules/resource_group/create_rg.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: location
    tags:tags
  }
}



// Create the Log Analytics Workspace
module r_logAnalyticsWorkspace 'modules/monitor/log_analytics_workspace.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${logAnalyticsWorkspaceParams.workspaceName}_${deploymentParams.global_uniqueness}_La'
  params: {
    deploymentParams:deploymentParams
    logAnalyticsWorkspaceParams: logAnalyticsWorkspaceParams
    tags: tags
  }
}

// Create Data Collection Endpoint
module r_dataCollectionEndpoint 'modules/monitor/data_collection_endpoint.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${dceParams.endpointNamePrefix}_${deploymentParams.global_uniqueness}_Dce'
  params: {
    deploymentParams:deploymentParams
    dceParams: dceParams
    osKind: 'linux'
    tags: tags
  }
}


// Create the Data Collection Rule
module r_dataCollectionRule 'modules/monitor/data_collection_rule.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${logAnalyticsWorkspaceParams.workspaceName}_${deploymentParams.global_uniqueness}_Dcr'
  params: {
    deploymentParams:deploymentParams
    osKind: 'Linux'
    tags: tags

    storeEventsRuleName: 'storeEvents_Dcr'
    storeEventsLogFilePattern: '/var/log/miztiik*.json'
    storeEventscustomTableNamePrefix: r_logAnalyticsWorkspace.outputs.storeEventsCustomTableNamePrefix

    automationEventsRuleName: 'miztiikAutomation_Dcr'
    automationEventsLogFilePattern: '/var/log/miztiik-automation-*.log'
    automationEventsCustomTableNamePrefix: r_logAnalyticsWorkspace.outputs.automationEventsCustomTableNamePrefix

    linDataCollectionEndpointId: r_dataCollectionEndpoint.outputs.linDataCollectionEndpointId
    logAnalyticsPayGWorkspaceName:r_logAnalyticsWorkspace.outputs.logAnalyticsPayGWorkspaceName
    logAnalyticsPayGWorkspaceId:r_logAnalyticsWorkspace.outputs.logAnalyticsPayGWorkspaceId

  }
  dependsOn: [
    r_logAnalyticsWorkspace
  ]
}


// // Create Key Vault
// module r_kv 'modules/keyvault/create_kv.bicep' = {
//   scope: resourceGroup(r_rg.name)
//   name: '${storageAccountParams.storageAccountNamePrefix}_${deploymentParams.global_uniqueness}_Kv'
//   params: {
//     deploymentParams:deploymentParams
//     kvNamePrefix:'storeEventsKv'
//     tags: tags
//   }
// }

//Create App Config
module r_appConfig 'modules/app_config/create_app_config.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${storageAccountParams.storageAccountNamePrefix}_${deploymentParams.global_uniqueness}_Config'
  params: {
    deploymentParams:deploymentParams
    appConfigParams: appConfigParams
    tags: tags
  }
}

// Create Storage Account
module r_sa 'modules/storage/create_storage_account.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${storageAccountParams.storageAccountNamePrefix}_${deploymentParams.global_uniqueness}_Sa'
  params: {
    deploymentParams:deploymentParams
    storageAccountParams:storageAccountParams
    appConfigName: r_appConfig.outputs.appConfigName
    tags: tags
  }
}


// Create Storage Account - Blob container
module r_blob 'modules/storage/create_blob.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${storageAccountParams.storageAccountNamePrefix}_${deploymentParams.global_uniqueness}_Blob'
  params: {
    deploymentParams:deploymentParams
    storageAccountParams:storageAccountParams
    storageAccountName: r_sa.outputs.saName
    appConfigName: r_appConfig.outputs.appConfigName
    tags: tags
  }
  dependsOn: [
    r_sa
  ]
}

// Create Storage Queue
module r_storageQueue 'modules/storage/create_storage_queue.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${storageAccountParams.storageAccountNamePrefix}_${deploymentParams.global_uniqueness}_Sq'
  params: {
    deploymentParams:deploymentParams
    storageQueueParams:storageQueueParams
    saName: r_sa.outputs.saName
    appConfigName: r_appConfig.outputs.appConfigName
    tags: tags
  }
  dependsOn: [
    r_sa
  ]
}


// Create the function app
module r_functionApp 'modules/functions/create_function.bicep' = {
  scope: resourceGroup(r_rg.name)
  name: '${storageAccountParams.storageAccountNamePrefix}_${deploymentParams.global_uniqueness}_Fa'
  params: {
    deploymentParams:deploymentParams
    funcParams: funcParams
    saName: r_sa.outputs.saName
    // appConfigName: r_appConfig.outputs.appConfigName
    tags: tags
  }
  dependsOn: [
    r_sa
  ]
}
