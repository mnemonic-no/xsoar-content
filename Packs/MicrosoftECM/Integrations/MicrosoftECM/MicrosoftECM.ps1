. $PSScriptRoot\CommonServerPowerShell.ps1
$COLLECTION_TYPE_MAPPING = @{
    "0" = "Root"
    "1" = "User"
    "2" = "Device"
    "3" = "Unknown"
}
$COLLECTION_CURRENT_STATUS_MAPPING = @{
    "0" = "NONE"
    "1" = "READY"
    "2" = "REFRESHING"
    "3" = "SAVING"
    "4" = "EVALUATING"
    "5" = "AWAITING_REFRESH"
    "6" = "DELETING"
    "7" = "APPENDING_MEMBER"
    "8" = "QUERYING"
}
$SCRIPT_APPROVAL_STATE = @{
    "0" = "Waiting for approval"
    "1" = "Declined"
    "3" = "Approved"
}
<#
.DESCRIPTION
This function converts a datetime object onto ISO format string

.PARAMETER date
The date that should be parsed

.OUTPUTS
Return The String representation of the datetime object normalized to UTC if or $null if $date is $null
#>
Function ParseDateTimeObjectToIso($date)
{
    if ($date)
    {
        return $date.ToUniversalTime().ToString("yyyy-mm-ddTHH:MM:ssZ")
    }
    return $null
}
<#
.DESCRIPTION
This function Verifies only one of the following arguments was actually given and throws an exception if not.

.PARAMETER $errorMessage
The error message with which the error should be raised

.PARAMETER $parameters
The parameters list from which only non-null parameter should be given
#>
Function AssertNoMoreThenOneParameterGiven
{
    param([Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string] $errorMessage,
        [Parameter(Mandatory = $true, Position = 1, ValueFromRemainingArguments = $true)]
        [AllowEmptyString()]
        [string[]] $parameters)
    if (([array]($parameters| where-Object { !!$_ })).Length -gt 1)
    {
        throw "Parameter set cannot be resolved using the specified named parameters. $errorMessage"
    }
}

<#
.DESCRIPTION
This function Verifies none of the following arguments was actually given and throws an exception if it was.

.PARAMETER $errorMessage
The error message with which the error should be raised

.PARAMETER $parameters
The parameters list from which all parameters should be null
#>
Function AssertNoParameterGiven
{
    param([Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string] $errorMessage,
        [Parameter(Mandatory = $true, Position = 1, ValueFromRemainingArguments = $true)]
        [AllowEmptyString()]
        [string[]] $parameters)
    if (([array]($parameters| where-Object { !!$_ })).Length -gt 0)
    {
        throw "Parameter set cannot be resolved using the specified named parameters. $errorMessage"
    }
}

<#
.DESCRIPTION
This function Verifies only one of the following arguments was actually given and throws an exception if not.
For more info see https://docs.microsoft.com/en-us/powershell/module/configurationmanager/get-cmcollection?view=sccm-ps

.PARAMETER collection_id
Specifies a collection ID

.PARAMETER collection_name
Specifies a collection name

.PARAMETER distribution_point_group_id
Specifies the ID of the distribution point group that is associated with the collection

.PARAMETER distribution_point_group_name
Specifies the name of the distribution point group that is associated with a collection

.OUTPUTS
Return the used parameter or throws an exception if more then one is used
#>
Function ValidateGetCollectionListParams($collection_id, $collection_name, $distribution_point_group_id, $distribution_point_group_name)
{
    AssertNoMoreThenOneParameterGiven "Please select only one of: collection_id, collection_name, distribution_point_group_id, distribution_point_group_name."  `
    $collection_id $collection_name $distribution_point_group_id $distribution_point_group_name
    $result = ""
    if ($collection_id)
    {
        $result = "collection_id"
    }
    elseif ($collection_name)
    {
        $result = "collection_name"
    }
    elseif ($distribution_point_group_id)
    {
        $result = "distribution_point_group_id"
    }
    elseif ($distribution_point_group_name)
    {
        $result = "distribution_point_group_name"
    }
    Return $result
}
<#
.DESCRIPTION
This function Verifies only one of the following arguments was actually given and throws an exception if not.
For more info see https://docs.microsoft.com/en-us/powershell/module/ConfigurationManager/Get-CMDevice?view=sccm-ps

.PARAMETER collection_id
Specifies a collection ID

.PARAMETER collection_name
Specifies a collection name

.PARAMETER device_name
Specifies the name of the device

.PARAMETER resource_id
Specifies the resource ID of a device

.PARAMETER threat_id
Specifies an ID of a threat

.PARAMETER threat_name
Specifies the a name of a threat

.OUTPUTS
Return the used parameters or throws an exception if parameter set cannot be resolved
#>
Function ValidateGetDeviceListParams($collection_id, $collection_name, $device_name, $resource_id, $threat_id, $threat_name)
{
    if ($device_name)
    {
        AssertNoParameterGiven "device_name parameter can be resolved only with collection_name or collection_id" $resource_id $threat_id $threat_name
        if ($collection_name)
        {
            AssertNoParameterGiven "device_name parameter can be resolved with collection_name or collection_id, not both" $collection_id
            return "device_name&collection_name"
        }
        elseif ($collection_id)
        {
            return "device_name&collection_id"
        }
        return "device_name"
    }
    if ($collection_id)
    {
        AssertNoParameterGiven "collection_id parameter can be resolved only with device_name, threat_id or threat_name" $collection_name $resource_id
        if ($threat_id)
        {
            return "collection_id&threat_id"
        }
        elseif($threat_name)
        {
            return "collection_id&threat_name"
        }
        throw "collection_id parameter can be resolved only with device_name, threat_id or threat_name"
    }
    if ($resource_id)
    {
        AssertNoParameterGiven "resource_id must be resolved with no other parameter" $collection_id $collection_name $device_name $threat_id $threat_name
        return "resource_id"
    }
    return ""
}
<#
.DESCRIPTION
This function Verifies only one of the following arguments was actually given and throws an exception if not.
For more info see https://docs.microsoft.com/en-us/powershell/module/configurationmanager/new-cmscript?view=sccm-ps

.PARAMETER script_file_entry_id
Specifies the script file entry id ID

.PARAMETER script_text
Specifies the script code string content

.OUTPUTS
Return the used parameters or throws an exception if parameter set cannot be resolved
#>
Function ValidateCreateScriptParams($script_file_entry_id, $script_text)
{
    AssertNoMoreThenOneParameterGiven "script_file_entry_id cannot be resolved with script_text" $script_file_entry_id $script_text
    if (!$script_file_entry_id -And !$script_text)
    {
        throw "Please supply either script_file_entry_id or script_text"
    }
    if ($script_file_entry_id)
    {
        return "script_path"
    }
    return "script_text"
}
<#
.DESCRIPTION
This function Verifies a valid parameter set is used with excactly one of $collection_id $collection_name and one of $include_collection_id $include_collection_name
For more info see https://docs.microsoft.com/en-us/powershell/module/configurationmanager/add-cmdevicecollectionincludemembershiprule?view=sccm-ps

.PARAMETER collection_id
Specifies the collection ID

.PARAMETER collection_name
Specifies the collection name

.PARAMETER collection_id
Specifies the collection ID to include\exclude in the membership rule

.PARAMETER collection_name
Specifies the collection name to include\exclude in the membership rule

.OUTPUTS
Return the used parameters or throws an exception if parameter set cannot be resolved
#>
Function ValidateIncludeOrExcludeDeviceCollectionParameters($collection_id, $collection_name, $include_collection_id, $include_collection_name)
{
    AssertNoMoreThenOneParameterGiven "Can only use one of the following parameters: collection_name, collection_id" $collection_name $collection_id
    if (!$collection_id -And !$collection_name)
    {
        throw "Must use one of the following parameters: collection_id, collection_name"
    }
    AssertNoMoreThenOneParameterGiven "Can only use one of the following parameters: include\exclude_collection_name, include\exclude_collection_id" $include_collection_name $include_collection_id
    if (!$include_collection_id -And !$include_collection_name)
    {
        throw "Must use one of the following parameters: include\exclude_collection_id, include\exclude_collection_name"
    }
    if ($collection_id -And $include_collection_id)
    {
        return "id&id"
    }
    if ($collection_id -And $include_collection_name)
    {
        return "id&name"
    }
    if ($collection_name -And $include_collection_id)
    {
        return "name&id"
    }
    if ($collection_name -And $include_collection_name)
    {
        return "name&name"
    }
}
<#
.DESCRIPTION
This function Parses A configuration manager collection object into PSCustomObject with selected keys.

.PARAMETER collection
Specifies collection to parse

.OUTPUTS
Return the PSCustomObject with the selected collection keys
#>
Function ParseCollectionObject($collection)
{
    [PSCustomObject]@{
        Name = $collection.Name
        ID = $collection.CollectionID
        Type = $COLLECTION_TYPE_MAPPING["$( $collection.CollectionType )"]
        Comment = $collection.Comment
        CurrentStatus = $COLLECTION_CURRENT_STATUS_MAPPING["$( $collection.CurrentStatus )"]
        CollectionRules = ($collection.CollectionRules -Join ",")
        HasProvisionedMember = "$( $collection.HasProvisionedMember )"
        IncludeExcludeCollectionsCount = "$( $collection.IncludeExcludeCollectionsCount )"
        IsBuiltIn = "$( $collection.IsBuiltIn )"
        IsReferenceCollection = "$( $collection.IsReferenceCollection )"
        LastChangeTime = ParseDateTimeObjectToIso $collection.LastChangeTime
        LastMemberChangeTime = ParseDateTimeObjectToIso $collection.LastMemberChangeTime
        LastRefreshTime = ParseDateTimeObjectToIso $collection.LastRefreshTime
        LimitToCollectionID = $collection.LimitToCollectionID
        LimitToCollectionName = $collection.LimitToCollectionName
        LocalMemberCount = "$( $collection.LocalMemberCount )"
        MemberClassName = "$( $collection.MemberClassName )"
        MemberCount = "$( $collection.MemberCount )"
        UseCluster = "$( $collection.UseCluster )"
    }
}
<#
.DESCRIPTION
This function Parses A configuration manager script invocation object into PSCustomObject with selected keys and return the outputs to the context.

.PARAMETER collection
Specifies collection to parse

.OUTPUTS
Return the PSCustomObject with the selected collection keys
#>
Function ParseScriptInvocationResults($result, $HumanReadableTitle)
{
    if ($result)
    {
        $output = [PSCustomObject]@{
            "MicrosoftECM.ScriptsInvocation(val.OperationID && val.OperationID === obj.OperationID)" = [PSCustomObject]@{
                OperationID = $result.OperationID
                ReturnValue = "$( $result.ReturnValue )"
            }
        }
        $MDOutput = $output."MicrosoftECM.ScriptsInvocation(val.OperationID && val.OperationID === obj.OperationID)" | TableToMarkdown -Name $HumanReadableTitle
        ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $result | Out-Null
    }
    else
    {
        $output = @()
        $MDOutput = $output | TableToMarkdown -Name $HumanReadableTitle
        ReturnOutputs $MDOutput | Out-Null
    }
}

<#
.DESCRIPTION
This function Parses A configuration manager script object into PSCustomObject with selected keys and return it's outputs.

.PARAMETER script
Specifies script to parse

.OUTPUTS
Return the PSCustomObject with the selected script keys
#>
Function ParseScriptObject($script)
{
    if ($script)
    {
        $output = [PSCustomObject]@{
            "MicrosoftECM.Scripts(val.ScriptGuid && val.ScriptGuid === obj.ScriptGuid)" = $script | ForEach-Object {
                [PSCustomObject]@{
                    ApprovalState = $SCRIPT_APPROVAL_STATE["$( $_.ApprovalState )"]
                    Approver = $_.Approver
                    Author = $_.Author
                    Comment = $_.Comment
                    LastUpdateTime = ParseDateTimeObjectToIso $_.LastUpdateTime
                    Parameterlist = $_.Parameterlist
                    Script = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String("$( $_.Script )")|?{ $_ })).Substring(2)
                    ScriptGuid = $_.ScriptGuid
                    ScriptHash = $_.ScriptHash
                    ScriptHashAlgorithm = $_.ScriptHashAlgorithm
                    ScriptName = $_.ScriptName
                    ScriptType = $_.ScriptType
                    ScriptVersion = $_.ScriptVersion
                }
            }
        }
        $MDOutput = $output."MicrosoftECM.Scripts(val.ScriptGuid && val.ScriptGuid === obj.ScriptGuid)" | TableToMarkdown -Name "Scripts List"
        ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $script | Out-Null
    }
    else
    {
        $output = @()
        $MDOutput = $output | TableToMarkdown -Name "Scripts List"
        ReturnOutputs $MDOutput | Out-Null
    }
}
<#
.DESCRIPTION
This function Executes a script, approves it and runs it on the configuration manager.
If a script with that name already exists - this script will be used and new script will not be created.

.PARAMETER device_name
Specifies device name to run this script in

.PARAMETER collection_id
Specifies collection to run this script in

.PARAMETER collection_name
Specifies collection to run this script in

.PARAMETER script_text
Specifies the script text that should be run.

.PARAMETER script_name
Specifies the name of the script

.OUTPUTS
Return the A script invocation object with the invocation results
#>
Function ExecuteServiceScript($device_name, $collection_id, $collection_name, $script_text, $script_name)
{
    AssertNoMoreThenOneParameterGiven "Can only use one of the following parameters: device_name, collection_id, collection_name" $device_name $collection_id $collection_name
    if (!$device_name -And !$collection_id -And !$collection_name)
    {
        throw "Must use one of the following parameters: device_name, collection_id, collection_name"
    }
    $result = Invoke-Command $global:Session -ArgumentList $global:SiteCode, $collection_id, $collection_name, $device_name, $script_text, $script_name -ErrorAction Stop -ScriptBlock {
        param($SiteCode, $collection_id, $collection_name, $device_name, $script_text, $script_name)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"

        # Checking if script exists in the configuration ConfigurationManager
        $CMPSSuppressFastNotUsedCheck = $true
        $Script = Get-CMScript -ScriptName $script_name
        if (!$Script)
        {
            Try
            {
                $script = New-CMScript -ScriptText $script_text -ScriptName $script_name
            }
            catch
            {
                throw "Failed to create script $script_name. Error: [$( $_.Exception.Message )]"
            }
            try
            {
                Approve-CMScript -ScriptGuid $script.ScriptGuid -Comment "XSOAR StartService script"
            }
            catch
            {
                throw "Failed to approve script $script_name. Error: [$( $_.Exception.Message )]"
            }
        }
        try
        {
            if ($device_name)
            {
                $Device = Get-CMDevice -Name $device_name
                Invoke-CMScript -ScriptGuid $script.ScriptGuid -Device $Device -PassThru
            }
            elseif ($collection_id)
            {
                Invoke-CMScript -ScriptGuid $script.ScriptGuid -CollectionId $collection_id -PassThru
            }
            elseif ($collection_name)
            {
                Invoke-CMScript -ScriptGuid $script.ScriptGuid -CollectionName $collection_name -PassThru
            }
        }
        catch
        {
            throw "Failed to invoke script $script_name. Error: [$( $_.Exception.Message )]"
        }
    }
    $result
}

Function GetLastLogOnUser($deviceName)
{
    $device = Invoke-Command $global:Session -ArgumentList $deviceName, $global:siteCode -ErrorAction Stop -ScriptBlock {
        param($deviceName, $siteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        Get-CMResource -ResourceType System -Fast |Where-Object { $_.Name -eq $deviceName }

    }
    if ($device)
    {
        $output = [PSCustomObject]@{
            "MicrosoftECM.LastLogOnUser" = [PSCustomObject]@{
                CreationDate = ParseDateTimeObjectToIso $device.CreationDate
                IP = ($device.IPAddresses | Out-String).Replace("`n", " ")
                Name = $device.Name
                LastLogonTimestamp = $device.LastLogonTimestamp | ParseDateTimeObjectToIso
                LastLogonUserName = $device.LastLogonUserName
            }
        }
        $MDOutput = $output."MicrosoftECM.LastLogOnUser" | TableToMarkdown -Name "Last loggon user on $deviceName"
        ReturnOutputs -ReadableOutput $MDOutput -Outputs $Output -RawResponse $device
    }
    else
    {
        throw "Could not find a computer with the name $deviceName"
    }
}

Function GetPrimaryUser($deviceName)
{
    $user_device_affinity = Invoke-Command $global:Session -ArgumentList $deviceName, $global:siteCode -ErrorAction Stop -ScriptBlock {
        param($deviceName, $siteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        $device = Get-CMDevice -Name $deviceName -Fast
        if (!$device)
        {
            throw "Could not find a computer with the name $computerName"
        }
        Get-CMUserDeviceAffinity -DeviceName $deviceName
    }
    if ($user_device_affinity)
    {
        $output = [PSCustomObject]@{
            'MicrosoftECM.PrimaryUsers' = $user_device_affinity | ForEach-Object {
                [PSCustomObject]@{
                    MachineName = $_.ResourceName
                    UserName = $_.UniqueUserName
                }
            }
        }
        $MDOutput = $output."MicrosoftECM.PrimaryUsers" | TableToMarkdown -Name "Primary users on $computerName"
        ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $user_device_affinity
    }
    else
    {
        $output = @()
        $MDOutput = $output | TableToMarkdown -Name "Primary users on $computerName"
        ReturnOutputs $MDOutput
    }
}

Function GetCollectionList($collection_type, $collection_id, $collection_name, $distribution_point_group_id, $distribution_point_group_name)
{
    $usedParameterName = ValidateGetCollectionListParams $collection_id $collection_name $distribution_point_group_id $distribution_point_group_name
    $parameters = @{
        usedParameterName = $usedParameterName
        collection_type = $collection_type
        collection_id = $collection_id
        collection_name = $collection_name
        distribution_point_group_id = $distribution_point_group_id
        distribution_point_group_name = $distribution_point_group_name
    }
    $Collections = Invoke-Command $global:Session -ArgumentList $parameters, $global:siteCode -ErrorAction Stop -ScriptBlock {
        param($parameters, $siteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        switch ($parameters.usedParameterName)
        {
            "collection_id" {
                Get-CMCollection -CollectionType $parameters.collection_type -Id $parameters.collection_id
            }
            "collection_name" {
                Get-CMCollection -CollectionType $parameters.collection_type -Name $parameters.collection_name
            }
            "distribution_point_group_id" {
                Get-CMCollection -CollectionType $parameters.collection_type -DistributionPointGroupId  $parameters.distribution_point_group_id
            }
            "distribution_point_group_name" {
                Get-CMCollection -CollectionType $parameters.collection_type -DistributionPointGroupName $parameters.distribution_point_group_name
            }
            default {
                Get-CMCollection -CollectionType $parameters.collection_type
            }
        }
    }
    if ($Collections)
    {
        $output = [PSCustomObject]@{
            "MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" = $Collections | ForEach-Object { ParseCollectionObject $_ }
        }
        $MDOutput = $output."MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" | TableToMarkdown -Name "Collection List"
        ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $Collections
    }
    else
    {
        $output = @()
        $MDOutput = $output | TableToMarkdown -Name "Collection List"
        ReturnOutputs $MDOutput
    }
}
Function GetDeviceList($collection_id, $collection_name, $device_name, $resource_id, $threat_id, $threat_name)
{
    $usedParameterName = ValidateGetDeviceListParams $collection_id $collection_name $device_name $resource_id $threat_id $threat_name
    $parameters = @{
        usedParameterName = $usedParameterName
        collection_id = $collection_id
        collection_name = $collection_name
        device_name = $device_name
        resource_id = $resource_id
        threat_id = $threat_id
        threat_name = $threat_name
    }
    $Devices = Invoke-Command $global:Session -ArgumentList $parameters, $global:siteCode -ErrorAction Stop -ScriptBlock {
        param($parameters, $siteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        switch ($parameters.usedParameterName)
        {
            "device_name" {
                Get-CMDevice -Name $parameters.device_name
            }
            "device_name&collection_name" {
                Get-CMDevice -CollectionName $parameters.collection_name -Name $parameters.device_name
            }
            "device_name&collection_id" {
                Get-CMDevice -CollectionId $parameters.collection_id -Name $parameters.device_name
            }
            "collection_id&threat_id" {
                Get-CMDevice -CollectionId $parameters.collection_id -ThreatId $parameters.threat_id
            }
            "collection_id&threat_name" {
                Get-CMDevice -CollectionId $parameters.collection_id -ThreatName $parameters.threat_name
            }
            "resource_id" {
                Get-CMDevice -ResourceId $parameters.resource_id
            }
            default {
                Get-CMDevice
            }
        }
    }
    if ($Devices)
    {
        $output = [PSCustomObject]@{
            "MicrosoftECM.Devices(val.ResourceID && val.ResourceID === obj.ResourceID)" = $Devices | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    ClientVersion = $_.ClientVersion
                    CurrentLogonUser = $_.CurrentLogonUser
                    DeviceAccessState = $_.DeviceAccessState
                    DeviceCategory = $_.DeviceCategory
                    DeviceOS = $_.DeviceOS
                    DeviceOSBuild = $_.DeviceOSBuild
                    Domain = $_.Domain
                    IsActive = "$_.IsActive"
                    LastActiveTime = ParseDateTimeObjectToIso $_.LastActiveTime
                    LastHardwareScan = ParseDateTimeObjectToIso $_.LastHardwareScan
                    LastInstallationError = ParseDateTimeObjectToIso $_.LastInstallationError
                    LastLogonUser = $_.LastLogonUser
                    LastMPServerName = $_.LastMPServerName
                    MACAddress = $_.MACAddress
                    PrimaryUser = $_.PrimaryUser
                    ResourceID = $_.ResourceID
                    SiteCode = $_.SiteCode
                    Status = $_.Status
                }
            }
        }
        $MDOutput = $output."MicrosoftECM.Devices(val.ResourceID && val.ResourceID === obj.ResourceID)" | TableToMarkdown -Name "Devices List"
        ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $Devices | Out-Null
    }
    else
    {
        $output = @()
        $MDOutput = $output | TableToMarkdown -Name "Devices List"
        ReturnOutputs $MDOutput | Out-Null
    }
}

Function GetScriptList($author, $script_name)
{
    $scripts = Invoke-Command $global:Session -ArgumentList $author, $script_name, $global:SiteCode -ErrorAction Stop -ScriptBlock {
        param($author, $script_name, $SiteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        $CMPSSuppressFastNotUsedCheck = $true
        if ($author -And $script_name)
        {
            Get-CMScript -Author $author -ScriptName $script_name
        }
        elseif ($author)
        {
            Get-CMScript -Author $author
        }
        elseif ($script_name)
        {
            Get-CMScript -ScriptName $script_name
        }
        else
        {
            Get-CMScript
        }
    }
    ParseScriptObject $scripts
}

Function CreateScript($script_file_entry_id, $script_text, $script_name)
{
    $usedParameterName = ValidateCreateScriptParams $script_file_entry_id $script_text
    $script_path = ""
    if ($script_file_entry_id)
    {
        $script_path = $demisto.GetFilePath($script_file_entry_id).path
        Copy-Item –Path $script_path –Destination "C:\$($script_path).ps1" –ToSession $session
    }
    $script = Invoke-Command $global:Session -ArgumentList $global:SiteCode, $usedParameterName, $script_path, $script_text, $script_name -ErrorAction Stop -ScriptBlock {
        param($SiteCode, $usedParameterName, $script_path, $script_text, $script_name)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        $CMPSSuppressFastNotUsedCheck = $true
        switch ("$usedParameterName")
        {
            "script_path" {
                New-CMScript -ScriptFile "C:\$($script_path).ps1" -ScriptName $script_name
            }
            "script_text" {
                New-CMScript -ScriptText $script_text -ScriptName $script_name
            }
        }
    }
    ParseScriptObject $script
}

Function InvokeScript($script_guid, $collection_id, $collection_name, $device_name)
{
    AssertNoMoreThenOneParameterGiven "Can only use one of the following parameters: collection_id, collection_name, device_name" $collection_id $collection_name $device_name
    If (!($collection_id -Or $collection_name -Or $device_name))
    {
        throw "Must use one of the following parameters: collection_id, collection_name, device_name"
    }
    $InvokedScript = Invoke-Command $global:Session -ArgumentList $global:SiteCode, $script_guid, $collection_id, $collection_name, $device_name -ErrorAction Stop -ScriptBlock {
        param($SiteCode, $script_guid, $collection_id, $collection_name, $device_name)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        $CMPSSuppressFastNotUsedCheck = $true
        if ($collection_id)
        {
            $scriptInvocation = Invoke-CMScript -ScriptGuid $script_guid -CollectionId $collection_id -PassThru
        }
        elseif ($collection_name)
        {
            $scriptInvocation = Invoke-CMScript -ScriptGuid $script_guid -CollectionName $collection_name -PassThru
        }
        elseif ($device_name)
        {
            $Device = Get-CMDevice -Name $device_name
            $scriptInvocation = Invoke-CMScript -ScriptGuid $script_guid -Device $Device -PassThru
        }
    }
    ParseScriptInvocationResults $InvokedScript "Script Invocation Result"
}

Function ApproveScript($script_guid, $comment)
{
    Invoke-Command $global:Session -ArgumentList $global:SiteCode, $script_guid, $comment -ErrorAction Stop -ScriptBlock {
        param($SiteCode, $script_guid, $comment)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        $CMPSSuppressFastNotUsedCheck = $true
        Approve-CMScript -ScriptGuid $script_guid -Comment $comment
    }
    $MDOutput = @() | TableToMarkdown -Name "Script Approved"
    ReturnOutputs $MDOutput | Out-Null
}

Function CreateDeviceCollection($comment, $collection_name, $limiting_collection_name)
{
    $collection = Invoke-Command $global:Session -ArgumentList $global:SiteCode, $comment, $collection_name, $limiting_collection_name -ErrorAction Stop -ScriptBlock {
        param($SiteCode, $comment, $collection_name, $limiting_collection_name)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        $CMPSSuppressFastNotUsedCheck = $true
        New-CMCollection -Name $collection_name -CollectionType "Device" -Comment $comment -LimitingCollectionName $limiting_collection_name
    }
    $output = [PSCustomObject]@{ "MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" = ParseCollectionObject $collection }
    $MDOutput = $output."MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" | TableToMarkdown -Name "Collection Created"
    ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $collection | Out-Null
}


Function AddMembersToDeviceCollection($collection_id, $collection_name, $device_resource_ids)
{
    AssertNoMoreThenOneParameterGiven "Can only use one of the following parameters: collection_name, collection_id" $collection_name $collection_id
    if (!$collection_name -And !$device_resource_ids)
    {
        throw "Must use one of the following parameters: collection_id, collection_name"
    }
    $resource_ids = ArgToList $device_resource_ids
    $result = Invoke-Command $global:Session -ArgumentList $global:SiteCode, $collection_id, $collection_name, $resource_ids -ErrorAction Stop -ScriptBlock {
        param($SiteCode, $collection_id, $collection_name, $resource_ids)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        $CMPSSuppressFastNotUsedCheck = $true
        if ($collection_id)
        {
            Add-CMDeviceCollectionDirectMembershipRule -ResourceId $resource_ids -CollectionId $collection_id -PassThru
        }
        else
        {
            Add-CMDeviceCollectionDirectMembershipRule -ResourceId $resource_ids -CollectionName $collection_name -PassThru
        }
    }
    $output = [PSCustomObject]@{ "MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" = ParseCollectionObject $result }
    $MDOutput = $output."MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" | TableToMarkdown -Name "Updated Collection"
    ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $result | Out-Null
}

Function IncludeDeviceCollection($collection_id, $collection_name, $include_collection_id, $include_collection_name)
{
    $usedParameterName = ValidateIncludeOrExcludeDeviceCollectionParameters $collection_id $collection_name $include_collection_id $include_collection_name
    $parameters = @{
        usedParameterName = $usedParameterName
        collection_id = $collection_id
        collection_name = $collection_name
        include_collection_id = $include_collection_id
        include_collection_name = $include_collection_name
    }
    $result = Invoke-Command $global:Session -ArgumentList $parameters, $global:siteCode -ErrorAction Stop -ScriptBlock {
        param($parameters, $siteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        switch ($parameters.usedParameterName)
        {
            "id&id" {
                Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $parameters.collection_id -IncludeCollectionId $parameters.include_collection_id -PassThru
            }
            "id&name" {
                Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $parameters.collection_id -IncludeCollectionName $parameters.include_collection_name -PassThru
            }
            "name&id" {
                Add-CMDeviceCollectionIncludeMembershipRule -CollectionName $parameters.collection_name -IncludeCollectionId $parameters.include_collection_id -PassThru
            }
            "name&name" {
                Add-CMDeviceCollectionIncludeMembershipRule -CollectionName $parameters.collection_name -IncludeCollectionName $parameters.include_collection_name -PassThru
            }
        }
    }
    $output = [PSCustomObject]@{ "MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" = ParseCollectionObject $result }
    $MDOutput = $output."MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" | TableToMarkdown -Name "Updated Collection"
    ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $result | Out-Null
}

Function ExcludeDeviceCollection($collection_id, $collection_name, $exclude_collection_id, $exclude_collection_name)
{
    $usedParameterName = ValidateIncludeOrExcludeDeviceCollectionParameters $collection_id $collection_name $exclude_collection_id $exclude_collection_name
    $parameters = @{
        usedParameterName = $usedParameterName
        collection_id = $collection_id
        collection_name = $collection_name
        exclude_collection_id = $exclude_collection_id
        exclude_collection_name = $exclude_collection_name
    }
    $result = Invoke-Command $global:Session -ArgumentList $parameters, $global:siteCode -ErrorAction Stop -ScriptBlock {
        param($parameters, $siteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        switch ($parameters.usedParameterName)
        {
            "id&id" {
                Add-CMDeviceCollectionExcludeMembershipRule -CollectionId $parameters.collection_id -ExcludeCollectionId $parameters.exclude_collection_id -PassThru
            }
            "id&name" {
                Add-CMDeviceCollectionExcludeMembershipRule -CollectionId $parameters.collection_id -ExcludeCollectionName $parameters.exclude_collection_name -PassThru
            }
            "name&id" {
                Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $parameters.collection_name -ExcludeCollectionId $parameters.exclude_collection_id -PassThru
            }
            "name&name" {
                Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $parameters.collection_name -ExcludeCollectionName $parameters.exclude_collection_name -PassThru
            }
        }
    }
    $output = [PSCustomObject]@{ "MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" = ParseCollectionObject $result }
    $MDOutput = $output."MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" | TableToMarkdown -Name "Updated Collection"
    ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $result | Out-Null
}

Function AddMembersToCollectionByQuery($collection_id, $collection_name, $query_expression, $rule_name)
{
    if (!$collection_id -And !$collection_name)
    {
        throw "Must use one of the following parameters: collection_id, collection_name"
    }
    $result = Invoke-Command $global:Session -ArgumentList $global:siteCode, $collection_id, $collection_name, $query_expression, $rule_name -ErrorAction Stop -ScriptBlock {
        param($siteCode, $collection_id, $collection_name, $query_expression, $rule_name)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        if ($collection_id)
        {
            Add-CMDeviceCollectionQueryMembershipRule -CollectionId $collection_id -RuleName $rule_name -QueryExpression $query_expression -PassThru
        }
        else
        {
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $collection_name -RuleName $rule_name -QueryExpression $query_expression -PassThru
        }
    }
    $output = [PSCustomObject]@{ "MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" = ParseCollectionObject $result }
    $MDOutput = $output."MicrosoftECM.Collections(val.ID && val.ID === obj.ID)" | TableToMarkdown -Name "Updated Collection"
    ReturnOutputs -ReadableOutput $MDOutput -Outputs $output -RawResponse $result | Out-Null
}

Function StartService($service_name, $collection_id, $collection_name, $device_name)
{
    $script_text = "Get-Service $service_name | Start-Service -PassThru -ErrorAction Stop"
    $script_name = "XSOAR StartService"
    $result = ExecuteServiceScript $device_name $collection_id $collection_name $script_text $script_name
    ParseScriptInvocationResults $result "StartService script Invocation Result"
}

Function RestartService($service_name, $collection_id, $collection_name, $device_name)
{
    $script_text = "Get-Service $service_name | Restart-Service -PassThru -ErrorAction Stop"
    $script_name = "XSOAR RestartService"
    $result = ExecuteServiceScript $device_name $collection_id $collection_name $script_text $script_name
    ParseScriptInvocationResults $result "RestartService script Invocation Result"
}

Function StopService($service_name, $collection_id, $collection_name, $device_name)
{
    $script_text = "Get-Service $service_name | Stop-Service -PassThru -ErrorAction Stop"
    $script_name = "XSOAR StopService"
    $result = ExecuteServiceScript $device_name $collection_id $collection_name $script_text $script_name
    ParseScriptInvocationResults $result "StopService script Invocation Result"
}

Function TestModule()
{
    Invoke-Command $global:Session -ArgumentList $global:SiteCode -ErrorAction Stop -ScriptBlock {
        param($SiteCode)
        Set-Location $env:SMS_ADMIN_UI_PATH\..\
        Import-Module .\ConfigurationManager.psd1
        Set-Location "$( $SiteCode ):"
        if ((Get-Module -Name ConfigurationManager).Version -eq $null)
        {
            throw "Could not find SCCM modules in the SCCM machine"
        }
        $Devices = Get-CMResource -ResourceType System -Fast|Where-Object { $_.Name -ne $env:computername } | ForEach-Object { $_.Name }
    }
}

function Main
{
    # Parse Params
    $computerName = $demisto.Params()['ComputerName']
    $userName = $demisto.Params()['UserName']
    $password = $demisto.Params()['password']
    $global:SiteCode = $demisto.Params()['SiteCode']
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
    try
    {
        $global:Session = New-PSSession -ComputerName $computerName -Authentication Negotiate -Credential $Creds -ErrorAction Stop
        Switch ( $Demisto.GetCommand())
        {
            "test-module" {
                # $Demisto.Debug("Running test-module")
                TestModule | Out-Null
                ReturnOutputs "ok" | Out-Null
            }
            "ms-ecm-last-log-on-user" {
                $deviceName = $demisto.Args()['device_name']
                GetLastLogOnUser $deviceName | Out-Null
            }
            "ms-ecm-get-primary-user" {
                $deviceName = $demisto.Args()['device_name']
                GetPrimaryUser $deviceName | Out-Null
            }
            "ms-ecm-get-installed-softwares" {
                $deviceName = $demisto.Args()['device_name']
                ListInstalledSoftwares $deviceName | Out-Null
            }
            "ms-ecm-collection-list" {
                $collection_type = $demisto.Args()['collection_type']
                $collection_ID = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $distribution_point_group_id = $demisto.Args()['distribution_point_group_id']
                $distribution_point_group_name = $demisto.Args()['distribution_point_group_name']
                GetCollectionList $collection_type $collection_ID $collection_name $distribution_point_group_id $distribution_point_group_name
            }
            "ms-ecm-device-list" {
                $collection_ID = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $device_name = $demisto.Args()['device_name']
                $resource_id = $demisto.Args()['resource_id']
                $threat_id = $demisto.Args()['threat_id']
                $threat_name = $demisto.Args()['threat_name']
                GetDeviceList $collection_ID $collection_name $device_name $resource_id $threat_id $threat_name
            }
            "ms-ecm-scripts-list" {
                $author = $demisto.Args()['author']
                $script_name = $demisto.Args()['script_name']
                GetScriptList $author $script_name
            }
            "ms-ecm-script-create" {
                $script_file_entry_id = $demisto.Args()['script_file_entry_id']
                $script_text = $demisto.Args()['script_text']
                $script_name = $demisto.Args()['script_name']
                CreateScript $script_file_entry_id $script_text $script_name
            }
            "ms-ecm-script-invoke" {
                $script_guid = $demisto.Args()['script_guid']
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $device_name = $demisto.Args()['device_name']
                InvokeScript $script_guid $collection_id $collection_name $device_name
            }
            "ms-ecm-script-approve" {
                $script_guid = $demisto.Args()['script_guid']
                $comment = $demisto.Args()['comment']
                ApproveScript $script_guid $comment
            }
            "ms-ecm-device-collection-create" {
                $comment = $demisto.Args()['comment']
                $collection_name = $demisto.Args()['collection_name']
                $limiting_collection_name = $demisto.Args()['limiting_collection_name']
                CreateDeviceCollection $comment $collection_name $limiting_collection_name
            }
            "ms-ecm-device-collection-members-add" {
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $device_resource_ids = $demisto.Args()['device_resource_ids']
                AddMembersToDeviceCollection $collection_id $collection_name $device_resource_ids
            }
            "ms-ecm-device-collection-include" {
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $include_collection_id = $demisto.Args()['include_collection_id']
                $include_collection_name = $demisto.Args()['include_collection_name']
                IncludeDeviceCollection $collection_id $collection_name $include_collection_id $include_collection_name
            }
            "ms-ecm-device-collection-exclude" {
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $exclude_collection_id = $demisto.Args()['exclude_collection_id']
                $exclude_collection_name = $demisto.Args()['exclude_collection_name']
                ExcludeDeviceCollection $collection_id $collection_name $exclude_collection_id $exclude_collection_name
            }
            "ms-ecm-device-collection-members-by-query-add" {
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $query_expression = $demisto.Args()['query_expression']
                $rule_name = $demisto.Args()['rule_name']
                AddMembersToCollectionByQuery $collection_id $collection_name $query_expression $rule_name
            }
            "ms-ecm-start-service" {
                $service_name = $demisto.Args()['service_name']
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $device_name = $demisto.Args()['device_name']
                StartService $service_name $collection_id $collection_name $device_name
            }
            "ms-ecm-restart-service" {
                $service_name = $demisto.Args()['service_name']
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $device_name = $demisto.Args()['device_name']
                RestartService $service_name $collection_id $collection_name $device_name
            }
            "ms-ecm-stop-service" {
                $service_name = $demisto.Args()['service_name']
                $collection_id = $demisto.Args()['collection_id']
                $collection_name = $demisto.Args()['collection_name']
                $device_name = $demisto.Args()['device_name']
                StopService $service_name $collection_id $collection_name $device_name
            }
        }
    }
    catch
    {
        ReturnError -Message "Something has gone wrong in MicrosoftECM.ps1:Main() [$( $_.Exception.Message )]" -Err $_ | Out-Null
        return
    }
}

# Execute Main when not in Tests
if ($MyInvocation.ScriptName -notlike "*.tests.ps1" -AND -NOT$Test)
{
    Main
}
