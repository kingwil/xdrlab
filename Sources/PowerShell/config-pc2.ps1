Configuration config-pc2
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName ComputerManagementDsc

    node 'localhost'
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ActionAfterReboot = 'ContinueConfiguration'
        }

        WaitForADDomain 'contoso.com'
        {
            DomainName           = 'contoso.com'
            PsDscRunAsCredential = $Credential
            RestartCount = 2
        }

        Computer JoinDomain
        {
            DependsOn = '[WaitForADDomain]contoso.com'
            Name = 'pc-02'
            DomainName = 'contoso.com'
            Credential = $Credential
        }

        PendingReboot RebootAfterDomainJoin
        {
            Name = 'DomainJoin'
        }
    }
}