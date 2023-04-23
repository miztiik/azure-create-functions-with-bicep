param sites_akatst_name string = 'akatst'
param serverfarms_ASP_MiztiikEnterprisescreatefunctio_99bb_externalid string = '/subscriptions/1ac6fdb8-61a9-4e86-a871-1baff37cd9e3/resourceGroups/Miztiik_Enterprises_create_functions_with_bicep_003/providers/Microsoft.Web/serverfarms/ASP-MiztiikEnterprisescreatefunctio-99bb'

resource sites_akatst_name_resource 'Microsoft.Web/sites@2022-09-01' = {
  name: sites_akatst_name
  location: 'West Europe'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/1ac6fdb8-61a9-4e86-a871-1baff37cd9e3/resourceGroups/Miztiik_Enterprises_create_functions_with_bicep_003/providers/Microsoft.Insights/components/store-events-fnAppInsights-003'
  }
  kind: 'functionapp,linux'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_akatst_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_akatst_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_ASP_MiztiikEnterprisescreatefunctio_99bb_externalid
    reserved: true
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'Python|3.10'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '0909F8160BC49145E75E2806AEA7F2592F41D07A60BE68E40BE095FCA21A5BF5'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_akatst_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: sites_akatst_name_resource
  name: 'ftp'
  location: 'West Europe'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/1ac6fdb8-61a9-4e86-a871-1baff37cd9e3/resourceGroups/Miztiik_Enterprises_create_functions_with_bicep_003/providers/Microsoft.Insights/components/store-events-fnAppInsights-003'
  }
  properties: {
    allow: true
  }
}

resource sites_akatst_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: sites_akatst_name_resource
  name: 'scm'
  location: 'West Europe'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/1ac6fdb8-61a9-4e86-a871-1baff37cd9e3/resourceGroups/Miztiik_Enterprises_create_functions_with_bicep_003/providers/Microsoft.Insights/components/store-events-fnAppInsights-003'
  }
  properties: {
    allow: true
  }
}

resource sites_akatst_name_web 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: sites_akatst_name_resource
  name: 'web'
  location: 'West Europe'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/1ac6fdb8-61a9-4e86-a871-1baff37cd9e3/resourceGroups/Miztiik_Enterprises_create_functions_with_bicep_003/providers/Microsoft.Insights/components/store-events-fnAppInsights-003'
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'Python|3.10'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$akatst'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 200
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource sites_akatst_name_sites_akatst_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = {
  parent: sites_akatst_name_resource
  name: '${sites_akatst_name}.azurewebsites.net'
  location: 'West Europe'
  properties: {
    siteName: 'akatst'
    hostNameType: 'Verified'
  }
}