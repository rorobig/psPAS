﻿function Remove-PASAccount {
	<#
.SYNOPSIS
Deletes an account

.DESCRIPTION
Deletes a specific account in the Vault.
The user who runs this web service requires the "Delete Accounts" permission.
If running against a CyberArk version earlier than 10.4, you must specify the UseV9API switch parameter.

.PARAMETER AccountID
The unique ID  of the account to delete.
This is retrieved by the Get-PASAccount function.

.PARAMETER UseV9API
Specify this switch to force usage of the legacy API endpoint.

.EXAMPLE
Remove-PASAccount -AccountID 19_1

Deletes the account with AccountID of 19_1

.INPUTS
All parameters can be piped by propertyname

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
		[ValidateNotNullOrEmpty()]
		[Alias("id")]
		[string]$AccountID,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $false,
			ParameterSetName = "v9"
		)]
		[switch]$UseV9API
	)

	BEGIN {
		$MinimumVersion = [System.Version]"10.4"
	}#begin

	PROCESS {

		If($PSCmdlet.ParameterSetName -eq "V9") {

			#Create URL for request (earlier than 10.4)
			$URI = "$Script:BaseURI/$Script:PVWAAppName/WebServices/PIMServices.svc/Accounts/$AccountID"

		}

		Else {

			#check minimum version
			Assert-VersionRequirement -ExternalVersion $Script:ExternalVersion -RequiredVersion $MinimumVersion

			#Create URL for request (Version 10.4 onwards)
			$URI = "$Script:BaseURI/$Script:PVWAAppName/api/Accounts/$AccountID"

		}

		if($PSCmdlet.ShouldProcess($AccountID, "Delete Account")) {

			#Send request to webservice
			Invoke-PASRestMethod -Uri $URI -Method DELETE -WebSession $WebSession

		}

	}#process

	END {}#end
}