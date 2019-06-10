﻿function Remove-PASGroupMember {
	<#
.SYNOPSIS
Removes a vault user from a group

.DESCRIPTION
Removes an existing member from an existing group in the vault

.PARAMETER GroupID
The ID of the group

.PARAMETER Member
The name of the group member

.EXAMPLE
Remove-PASGroupMember -GroupID X1_Y2 -Member TargetUser

Removes TargetUser from group

.INPUTS
All parameters can be piped by property name

.OUTPUTS
None

.NOTES

.LINK

#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[parameter(
			Mandatory = $true,
			ValueFromPipelinebyPropertyName = $true
		)]
		[Alias("ID")]
		[string]$GroupID,

		[parameter(
			Mandatory = $true,
			ValueFromPipelinebyPropertyName = $true
		)]
		[Alias("UserName")]
		[string]$Member
	)

	BEGIN {
		$MinimumVersion = [System.Version]"10.5"
	}#begin

	PROCESS {

		Assert-VersionRequirement -ExternalVersion $Script:ExternalVersion -RequiredVersion $MinimumVersion

		#Create URL for request
		$URI = "$Script:BaseURI/$Script:PVWAAppName/API/UserGroups/$GroupID/members/$Member"

		if($PSCmdlet.ShouldProcess($GroupID, "Remove Group Member $Member")) {

			#send request to web service
			Invoke-PASRestMethod -Uri $URI -Method DELETE -WebSession $WebSession

		}

	}#process

	END {}#end

}