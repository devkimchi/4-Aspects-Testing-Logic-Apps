#
# This sets Integration Account to Logic App
#

Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $LogicAppName,
    [bool] [Parameter(Mandatory=$false)] $EnableIntegrationAccount = $false,
    [string] [Parameter(Mandatory=$false)] $IntegrationAccountName = $null
)

$integrationAccountPropertyName = "integrationAccount"
$integrationAccountPropertyValue = @{}
$integrationAccount = $null

# Gets the Logic App instance.
$logicApp = Get-AzureRmResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $LogicAppName `
            -ResourceType Microsoft.Logic/workflows

# Updates the Logic App instance.
if ($EnableIntegrationAccount -eq $true) {
    # Gets the Integration Account instance.
    $integrationAccount = Get-AzureRmResource `
                          -ResourceGroupName $ResourceGroupName `
                          -ResourceName $IntegrationAccountName `
                          -ResourceType Microsoft.Logic/integrationAccounts

    $integrationAccountPropertyValue.Id = $integrationAccount.ResourceId
    $logicApp.Properties | Add-Member -MemberType NoteProperty -Name $integrationAccountPropertyName -Value $integrationAccountPropertyValue -Force
} else {
    if ($logicApp.Properties.PSObject.Properties.Name -contains $integrationAccountPropertyName) {
        $logicApp.Properties.PSObject.Properties.Remove($integrationAccountPropertyName)
    }
}

$result = $logicApp | Set-AzureRmResource -Force

Remove-Variable integrationAccountPropertyName
Remove-Variable integrationAccountPropertyValue
Remove-Variable integrationAccount
Remove-Variable logicApp
Remove-Variable result
