
param deploymentParams object
param funcParams object
param tags object = resourceGroup().tags

param saName string

// @description('The name of the function app that you wish to create.')
// param appName string = 'fnapp${uniqueString(resourceGroup().id)}'

// Get Storage Account Reference
// Get reference of SA
resource r_sa 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: saName
}



resource r_fnHostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${funcParams.funcNamePrefix}-fnPlan-${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  kind: 'linux'
  sku: {
    // https://learn.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-sku-not-available-errors
    name: funcParams.skuName
    tier: funcParams.funcHostingPlanTier
    family: 'Y'
  }
  properties: {
    reserved: true
  }
}

// resource r_srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
//   name: '${appService.name}/web'
//   properties: {
//     repoUrl: repositoryUrl
//     branch: branch
//     isManualIntegration: true
//   }
// }

resource r_fnApp 'Microsoft.Web/sites@2021-03-01' = {
  name:  '${funcParams.funcNamePrefix}-fnApp-${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  // kind: 'functionapp'
  kind: 'functionapp,linux'  
  tags: tags
  identity: {
    type: 'SystemAssigned'
    // type: 'SystemAssigned, UserAssigned'
    //   userAssignedIdentities: {
    //     '${identity.id}': {}
    //   }
  }
  properties: {
    enabled: true
    reserved: true
    serverFarmId: r_fnHostingPlan.id
    clientAffinityEnabled: true
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'Python|3.10' //az webapp list-runtimes --linux || az functionapp list-runtimes --os linux -o table
      // ftpsState: 'FtpsOnly'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${saName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${r_sa.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${saName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${r_sa.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        // {
        //   name: 'FUNCTION_APP_EDIT_MODE'
        //   value: 'readwrite'
        // }
        // {
        //   name: 'FUNCTIONS_WORKER_RUNTIME'
        //   value: funcParams.funcRuntime
        // }
        // {
        //   name: 'dbServer'
        //   value: serverName
        // }
        // {
        //   name: 'dbName'
        //   value: sqlDBName
        // }
        // {
        //   name: 'dbUsername'
        //   value: dbUsername
        // }
        // {
        //   name: 'dbPassword'
        //   value: dbPassword
        // }
        // {
        //   name: 'eventhubConnectionString'
        //   value: eventhubConnectionString
        // }
        // {
        //   name: 'responsesEHConnectionString'
        //   value: responsesEHConnectionString
        // }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(funcParams.funcNamePrefix)
        }
        // {
        //   name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        //   value: applicationInsights.properties.InstrumentationKey
        // }
        // {
        //   name: 'PYTHON_ENABLE_WORKER_EXTENSIONS'
        //   value: '0'
        // }
      ]
    }

  }
}


// resource functionAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
//   parent: r_fnApp
//   name: 'appsettings'
//   properties: {
//     AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${saName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${r_sa.listKeys().keys[0].value}'
//     WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${saName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${r_sa.listKeys().keys[0].value}'
//     WEBSITE_CONTENTSHARE: toLower(funcParams.funcNamePrefix)
//     FUNCTIONS_EXTENSION_VERSION: '~4'
//     APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
//     FUNCTIONS_WORKER_RUNTIME: 'python'
//     WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG: 1
//     DatabaseConnectionString: ''
//   }
// }

resource zipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  parent: r_fnApp
  name: 'MSDeploy'
  properties: {
    packageUri: 'https://github.com/miztiik/azure-create-functions-with-bicep/raw/main/app2.zip'
  }
}

// Function App Binding
resource r_fnAppBinding 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  parent: r_fnApp
  name: '${r_fnApp.name}.azurewebsites.net'
  properties: {
    siteName: r_fnApp.name
    hostNameType: 'Verified'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${funcParams.funcNamePrefix}-fnAppInsights-${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

