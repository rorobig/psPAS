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
			Mock Invoke-PASRestMethod -MockWith {

				New-Object Byte[] 512

			}

			Mock Out-PASFile -MockWith { }

			$response = Export-PASPlatform -PlatformID SomePlatform -path "$env:Temp\testExport.zip"
		}

		Context 'Mandatory Parameters' {

			$Parameters = @{Parameter = 'PlatformID' },
			@{Parameter = 'path' }

			It 'specifies parameter <Parameter> as mandatory' -TestCases $Parameters {

				param($Parameter)

				(Get-Command Export-PASPlatform).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}



		Context 'Input' {

			It 'throws if path is invalid' {
				{ Export-PASPlatform -PlatformID SomePlatform -path A:\test.txt } | Should -Throw
			}

			It 'sends request' {

				Assert-MockCalled Invoke-PASRestMethod -Scope It -Times 1 -Exactly

			}

			It 'sends request to expected endpoint' {

				Assert-MockCalled Invoke-PASRestMethod -ParameterFilter {

					$URI -eq "$($Script:BaseURI)/API/Platforms/SomePlatform/Export?platformID=SomePlatform"

				} -Times 1 -Exactly -Scope It

			}

			It 'uses expected method' {

				Assert-MockCalled Invoke-PASRestMethod -ParameterFilter { $Method -match 'POST' } -Times 1 -Exactly -Scope It

			}

			It 'throws error if version requirement not met' {
				$Script:ExternalVersion = '1.0'
				{ Export-PASPlatform -PlatformID SomePlatform -path "$env:Temp\testExport.zip" } | Should -Throw
				$Script:ExternalVersion = '0.0'
			}

		}

	}

}