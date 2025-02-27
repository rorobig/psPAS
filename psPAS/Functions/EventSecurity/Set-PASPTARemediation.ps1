# .ExternalHelp psPAS-help.xml
Function Set-PASPTARemediation {
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true
		)]
		[boolean]$changePassword_SuspectedCredentialsTheft,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true
		)]
		[boolean]$changePassword_OverPassTheHash,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true
		)]
		[boolean]$reconcilePassword_SuspectedPasswordChange,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true
		)]
		[boolean]$pendAccount_UnmanagedPrivilegedAccount

	)

	BEGIN {

		Assert-VersionRequirement -RequiredVersion 10.4

	}#begin

	PROCESS {

		#Get all parameters that will be sent in the request
		$boundParameters = $PSBoundParameters | Get-PASParameter

		#Create URL for Request
		$URI = "$Script:BaseURI/API/pta/API/Settings/AutomaticRemediations/"


		#Create body of request
		$body = $boundParameters | ConvertTo-Json

		if ($PSCmdlet.ShouldProcess('PTA', 'Update Automatic Remediation Config')) {

			#send request to PAS web service
			$result = Invoke-PASRestMethod -Uri $URI -Method PATCH -Body $Body -WebSession $Script:WebSession

			If ($null -ne $result) {

				#Return Results
				$result.automaticRemediation | Add-ObjectDetail -typename 'psPAS.CyberArk.Vault.PTA.Remediation'

			}

		}

	}#process

	END { }#end

}