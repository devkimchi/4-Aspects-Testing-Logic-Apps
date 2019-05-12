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

    # Tests whether the cmdlet returns value or not.
    Context "When Logic App deployed with parameters" {
        $resourceDirectory = "$RootDirectory\src\Resources"
        $templateName = "LogicApp"

        $location = "australiasoutheast"
        $locationCode = "ause"
        $environmentCode = "dev"
        $workflowName = "test"
        $productOwnerCode = "devops"
    
        $logicAppManagedIdentityType = "None"
        $logicAppState = "Enabled"

        $output = az group deployment validate `
            -g $ResourceGroupName `
            --template-file $resourceDirectory\$templateName.json `
            --parameters `@$resourceDirectory\$templateName.parameters.json `
            | ConvertFrom-Json
        
        $result = $output.properties

        It "Should be deployed successfully" {
            $result.provisioningState | Should -Be "Succeeded"
        }

        It "Should have name of" {
            $expected = "$productOwnerCode-logapp-$locationCode-$environmentCode-$workflowName"

            $resource = $result.validatedResources[0]

            $resource.name | Should -Be $expected
        }

        It "Should be located in" {
            $resource = $result.validatedResources[0]

            $resource.location | Should -Be $location
        }

        It "Should have identity of" {
            $resource = $result.validatedResources[0]

            $resource.identity.type | Should -Be $logicAppManagedIdentityType
        }

        It "Should have state of" {
            $resource = $result.validatedResources[0]

            $resource.properties.state | Should -Be $logicAppState
        }
    }
}
