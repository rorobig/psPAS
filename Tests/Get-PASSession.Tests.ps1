Describe $($PSCommandPath -Replace '.Tests.ps1') {

	BeforeAll {
		#Get Current Directory
		$Here = Split-Path -Parent $PSCommandPath

		#Assume ModuleName from Repository Root folder
		$ModuleName = Split-Path (Split-Path $Here -Parent) -Leaf

		#Resolve Path to Module Directory
		$ModulePath = Resolve-Path "$Here\..\$ModuleName"

		#Define Path to Module Manifest
		$ManifestPath = Join-Path "$ModulePath" "$ModuleName.psd1"

		if ( -not (Get-Module -Name $ModuleName -All)) {

			Import-Module -Name "$ManifestPath" -ArgumentList $true -Force -ErrorAction Stop

		}

		$Script:RequestBody = $null
		$Script:BaseURI = 'https://SomeURL/SomeApp'
		$Script:ExternalVersion = '0.0'
		$Script:WebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

	}


	AfterAll {

		$Script:RequestBody = $null

	}

	InModuleScope $(Split-Path (Split-Path (Split-Path -Parent $PSCommandPath) -Parent) -Leaf ) {
		BeforeEach {
			Mock Get-PASLoggedOnUser -MockWith {
				[PSCustomObject]@{'Username' = 'SomeUser'; 'Prop2' = 'Val2' }
			}

			$response = Get-PASSession
		}
		Context 'Standard Operation' {

			It 'provides output' {

				$response | Should -Not -BeNullOrEmpty

			}

			It 'has output with expected number of properties' {

				($response | Get-Member -MemberType NoteProperty).length | Should -Be 4

			}

			It 'outputs object with expected typename' {

				$response | Get-Member | Select-Object -ExpandProperty typename -Unique | Should -Be psPAS.CyberArk.Vault.Session

			}

			It 'does not throw if Get-PASLoggedOnUser fails' {
				Mock Get-PASLoggedOnUser -MockWith {
					throw 'Some Error'
				}

				{ Get-PASSession } | Should -Not -Throw

			}

			It 'does provides output if Get-PASLoggedOnUser fails' {
				Mock Get-PASLoggedOnUser -MockWith {
					throw 'Some Error'
				}

				$response = Get-PASSession

				($response | Get-Member -MemberType NoteProperty).length | Should -Be 4

			}

		}

	}

}