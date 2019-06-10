function Invoke-PASCredVerify {
	<#
.SYNOPSIS
Marks account for immediate verification by the CPM.

.DESCRIPTION
Flags a managed account credentials for an immediate CPM password verification.
The "Initiate CPM password management operations" permission is required.

.PARAMETER AccountID
The unique ID  of the account to delete.
This is retrieved by the Get-PASAccount function.

.EXAMPLE
Invoke-PASCredVerify -AccountID 19_1

Will mark account with AccountID of 19_1 for Immediate CPM Verification

.INPUTS
SessionToken, AccountID, WebSession & BaseURI can be piped by  property name

.OUTPUTS
None

.NOTES
Can be used in versions from v9.10.

#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[parameter(
			Mandatory = $true,
			ValueFromPipelinebyPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[Alias("id")]
		[string]$AccountID
	)

	BEGIN {
		$MinimumVersion = [System.Version]"9.10"
	}#begin

	PROCESS {

		Assert-VersionRequirement -ExternalVersion $Script:ExternalVersion -RequiredVersion $MinimumVersion

		#Create URL for request
		$URI = "$Script:BaseURI/$Script:PVWAAppName/API/Accounts/$AccountID/Verify"

		if ($PSCmdlet.ShouldProcess($AccountID, "Mark for Immediate Verification")) {

			#send request to web service
			Invoke-PASRestMethod -Uri $URI -Method POST -WebSession $WebSession

		}

	}#process

	END { }#end

}