#
# This tests whether the ARM template for Logic App has been properly deployed or not.
#

Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $RootDirectory,
    [hashtable] [Parameter(Mandatory=$false)] $Secrets = $null,
    [bool] [Parameter(Mandatory=$false)] $IsLocal = $false,
    [string] [Parameter(Mandatory=$false)] $Username = $null,
    [string] [Parameter(Mandatory=$false)] $Password = $null,
    [string] [Parameter(Mandatory=$false)] $TenantId = $null
)

Describe "Logic App Deployment Tests" {
    # Init
    BeforeAll {
        if ($IsLocal -eq $false) {
            az login --service-principal -u $Username -p $Password -t $TenantId
        }
    }

    # Teardown
    AfterAll {
    }

    $resourceDirectory = "$RootDirectory\src\Resources"
    $templateName = "LogicApp"

    Context "When Logic App is deployed" {
        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppProvisioningState = "Succeeded"

        It "Should be valid" {
            $output.error | Should -BeNullOrEmpty
        }

        It "Should be deployed successfully" {
            $result.provisioningState | Should -Be $expectedLogicAppProvisioningState
        }
    }

    Context "When Logic App is deployed with location" {
        $locationCode = "jpw"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters locationCode=$locationCode `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppLocation = @{ `
            aue = "australiaeast"; `
            ause = "australiasoutheast"; `
            krc = "koreacentral"; `
            krs = "koreasouth"; `
            jpe = "japaneast"; `
            jpw = "japanwest"; `
            sea = "southeastasia"; `
            ea = "eastasia"; `
        }
        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"

        It "Should be located in $($expectedLogicAppLocation["$locationCode"])" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.location | Should -Be $expectedLogicAppLocation["$locationCode"]
        }
    }

    Context "When Logic App is deployed with name" {
        $locationCode = "jpw"
        $environmentCode = "dev"
        $workflowName = "test"
        $productOwnerCode = "devops"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters locationCode=$locationCode `
            --parameters environmentCode=$environmentCode `
            --parameters workflowName=$workflowName `
            --parameters productOwnerCode=$productOwnerCode `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"
        $expectedLogicAppInstanceName = "$productOwnerCode-logapp-$locationCode-$environmentCode-$workflowName"

        It "Should have name of $expectedLogicAppInstanceName" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.name | Should -Be $expectedLogicAppInstanceName
        }
    }

    Context "When Logic App is deployed without Managed Identity" {
        $logicAppManagedIdentityType = "None"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters logicAppManagedIdentityType=$logicAppManagedIdentityType `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"
        $expectedLogicAppManagedIdentityType = $logicAppManagedIdentityType

        It "Should have identity of $expectedLogicAppManagedIdentityType" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.identity.type | Should -Be $expectedLogicAppManagedIdentityType
        }
    }

    Context "When Logic App is deployed with Managed Identity" {
        $logicAppManagedIdentityType = "SystemAssigned"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters logicAppManagedIdentityType=$logicAppManagedIdentityType `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"
        $expectedLogicAppManagedIdentityType = $logicAppManagedIdentityType

        It "Should have identity of $expectedLogicAppManagedIdentityType" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.identity.type | Should -Be $expectedLogicAppManagedIdentityType
        }
    }

    Context "When Logic App is deployed with state Disabled" {
        $logicAppState = "Disabled"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters logicAppState=$logicAppState `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"
        $expectedLogicAppState = $logicAppState

        It "Should have state of $expectedLogicAppState" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.properties.state | Should -Be $expectedLogicAppState
        }
    }

    Context "When Logic App is deployed with state Enabled" {
        $logicAppState = "Enabled"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters logicAppState=$logicAppState `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"
        $expectedLogicAppState = $logicAppState

        It "Should have state of $expectedLogicAppState" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.properties.state | Should -Be $expectedLogicAppState
        }
    }

    Context "When Logic App is deployed without Integration Account" {
        $enableIntegrationAccount = "false"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters enableIntegrationAccount=$enableIntegrationAccount `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"

        It "Should have no Integration Account" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.properties.integrationAccount | Should -BeNullOrEmpty
        }
    }

    Context "When Logic App is deployed with Integration Account" {
        $locationCode = "ause"
        $environmentCode = "dev"
        $productOwnerCode = "devops"

        $enableIntegrationAccount = "true"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters enableIntegrationAccount=$enableIntegrationAccount `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedLogicAppResourceType = "Microsoft.Logic/workflows"
        $expectedIntegrationAccountName = "$productOwnerCode-intacc-$locationCode-$environmentCode"

        It "Should have Integration Account" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.properties.integrationAccount | Should -Not -BeNullOrEmpty
        }

        It "Should have Integration Account of the name ending with $expectedIntegrationAccountName" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedLogicAppResourceType }

            $resource.properties.integrationAccount.id | Should -BeLike "*$expectedIntegrationAccountName"
        }
    }

    Context "When Logic App is deployed with Diagnostic Settings Disabled" {
        $enableDiagnosticSettings = "false"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters enableDiagnosticSettings=$enableDiagnosticSettings `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedDiagnosticSettingsResourceType = "Microsoft.Logic/workflows/providers/diagnosticSettings"

        It "Should have no DiagnosticSettings" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }

            $resource | Should -BeNullOrEmpty
        }
    }

    Context "When Logic App is deployed with Diagnostic Settings Enabled" {
        $enableDiagnosticSettings = "true"
        $diagnosticSettingsLogsCategory = "WorkflowRuntime"
        $diagnosticSettingsLogsEnabled = "true"
        $diagnosticSettingsLogsRetentionEnabled = "true"
        $diagnosticSettingsLogsRetentionInDays = 30
        $diagnosticSettingsMetricsCategory = "AllMetrics"
        $diagnosticSettingsMetricsEnabled = "true"
        $diagnosticSettingsMetricsRetentionEnabled = "true"
        $diagnosticSettingsMetricsRetentionInDays = 30

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            --parameters enableDiagnosticSettings=$enableDiagnosticSettings `
            | ConvertFrom-Json
        
        $result = $output.properties

        $expectedDiagnosticSettingsResourceType = "Microsoft.Logic/workflows/providers/diagnosticSettings"
        $expectedDiagnosticSettingsLogsCategory = $diagnosticSettingsLogsCategory
        $expectedDiagnosticSettingsLogsEnabled = [bool] $diagnosticSettingsLogsEnabled
        $expectedDiagnosticSettingsLogsRetentionEnabled = [bool] $diagnosticSettingsLogsRetentionEnabled
        $expectedDiagnosticSettingsLogsRetentionInDays = $diagnosticSettingsLogsRetentionInDays

        $expectedDiagnosticSettingsMetricsCategory = $diagnosticSettingsMetricsCategory
        $expectedDiagnosticSettingsMetricsEnabled = [bool] $diagnosticSettingsMetricsEnabled
        $expectedDiagnosticSettingsMetricsRetentionEnabled = [bool] $diagnosticSettingsMetricsRetentionEnabled
        $expectedDiagnosticSettingsMetricsRetentionInDays = $diagnosticSettingsMetricsRetentionInDays

        It "Should have DiagnosticSettings" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }

            $resource | Should -Not -BeNullOrEmpty
        }

        It "Should contain logs of $expectedDiagnosticSettingsLogsCategory" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $log = $resource.properties.logs | Where-Object { $_.category -eq $expectedDiagnosticSettingsLogsCategory }

            $log | Should -Not -BeNullOrEmpty
        }

        It "Should contain logs of $expectedDiagnosticSettingsLogsCategory - enabled of $expectedDiagnosticSettingsLogsEnabled" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $log = $resource.properties.logs | Where-Object { $_.category -eq $expectedDiagnosticSettingsLogsCategory }

            $log.enabled | Should -Be $expectedDiagnosticSettingsLogsEnabled
        }

        It "Should contain logs of $expectedDiagnosticSettingsLogsCategory - retention enabled of $expectedDiagnosticSettingsLogsRetentionEnabled" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $log = $resource.properties.logs | Where-Object { $_.category -eq $expectedDiagnosticSettingsLogsCategory }

            $log.retention.enabled | Should -Be $expectedDiagnosticSettingsLogsRetentionEnabled
        }

        It "Should contain logs of $expectedDiagnosticSettingsLogsCategory - retention days of $expectedDiagnosticSettingsLogsRetentionInDays" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $log = $resource.properties.logs | Where-Object { $_.category -eq $expectedDiagnosticSettingsLogsCategory }

            $log.retention.days | Should -Be $expectedDiagnosticSettingsLogsRetentionInDays
        }

        It "Should contain metrics of $expectedDiagnosticSettingsMetricsCategory" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $metric = $resource.properties.metrics | Where-Object { $_.category -eq $expectedDiagnosticSettingsMetricsCategory }

            $metric | Should -Not -BeNullOrEmpty
        }

        It "Should contain metrics of $expectedDiagnosticSettingsMetricsCategory - enabled of $expectedDiagnosticSettingsMetricsEnabled" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $metric = $resource.properties.metrics | Where-Object { $_.category -eq $expectedDiagnosticSettingsMetricsCategory }

            $metric.enabled | Should -Be $expectedDiagnosticSettingsMetricsEnabled
        }

        It "Should contain metrics of $expectedDiagnosticSettingsMetricsCategory - retention enabled of $expectedDiagnosticSettingsMetricsRetentionEnabled" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $metric = $resource.properties.metrics | Where-Object { $_.category -eq $expectedDiagnosticSettingsMetricsCategory }

            $metric.retention.enabled | Should -Be $expectedDiagnosticSettingsMetricsRetentionEnabled
        }

        It "Should contain metrics of $expectedDiagnosticSettingsMetricsCategory - retention days of $expectedDiagnosticSettingsMetricsRetentionInDays" {
            $resource = $result.validatedResources | Where-Object { $_.type -eq $expectedDiagnosticSettingsResourceType }
            $metric = $resource.properties.metrics | Where-Object { $_.category -eq $expectedDiagnosticSettingsMetricsCategory }

            $metric.retention.days | Should -Be $expectedDiagnosticSettingsMetricsRetentionInDays
        }
    }
}
