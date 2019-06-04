#
# This runs tests against TimgerTrigger workflow.
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

Describe "Logic App Timer Trigger Tests" {
    $logapp = $null
    $workflow = $null

    # Init
    BeforeAll {
        if ($IsLocal -eq $false) {
            Login-AzureRmAccount -ServicePrincipal -Credential 
            az login --service-principal -u $Username -p $Password -t $TenantId
        }

        $resgrp = $(New-AzureRmResourceGroup -Name $ResourceGroupName)[0]
        $intacc = $(Get-AzureRmResource Get-AzureRmResource `
                  -ResourceGroupName $ResourceGroupName `
                  -ResourceType Microsoft.Logic/integrationAccounts)[0]
        $logapp = New-AzureRmLogicApp `
                  -ResourceGroupName $ResourceGroupName `
                  -Name $(New-Guid).Guid `
                  -Location $resgrp.Location `
                  -State Enabled `
                  -IntegrationAccountId $intacc.ResourceId
        $logapp = Get-AzureRmResource `
                  -ResourceId "$($resgrp.ResourceId)/providers/$($logapp.Outputs['logicAppName'].Value)"

        $workflow = Get-Content "$RootDirectory/src/LogicApps/TimerTrigger.json" | ConvertFrom-Json
    }

    # Teardown
    AfterAll {
        Remove-AzureRmResource -ResourceId $logapp.ResourceId -Force
    }

    Context "When timer is triggered" {
        $logapp.Properties.parameters = $workflow.parameters
        $logapp.Properties.definition.parameters = $workflow.definition.parameters
        $logapp.Properties.definition.triggers = @{ manual = $workflow.definition.triggers.manual }
        $logapp.Properties.definition.actions = @{ GetMessagesFromTopicSubscription = $workflow.definition.actions.GetMessagesFromTopicSubscription }
        $logapp.Properties.definition.actions.GetMessagesFromTopicSubscription.runtimeConfiguration.staticResult.staticResultOptions = "Enabled"

        $result = $logapp | Set-AzureRmResource -Force
    }
}
