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

        Context 'Input' {

            $Script:BaseURI = 'https://SomeURL/SomeApp'
            $Script:ExternalVersion = '0.0'
            $Script:WebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

            BeforeEach {

                Mock Invoke-PASRestMethod -MockWith {
                    [PSCustomObject]@{
                        'Password' = 'SomePassword'
                    }
                }

                New-PASAccountPassword -AccountID 12_3

            }

            It 'sends request' {

                Assert-MockCalled Invoke-PASRestMethod -Times 1 -Exactly -Scope It

            }

            It 'sends request to expected endpoint' {

                Assert-MockCalled Invoke-PASRestMethod -ParameterFilter {

                    $URI -eq "$($Script:BaseURI)/api/Accounts/12_3/Secret/Generate"

                } -Times 1 -Exactly -Scope It

            }

            It 'uses expected method' {

                Assert-MockCalled Invoke-PASRestMethod -ParameterFilter { $Method -match 'POST' } -Times 1 -Exactly -Scope It

            }

            It 'sends request with no body' {

                Assert-MockCalled Invoke-PASRestMethod -ParameterFilter { $Body -eq $null } -Times 1 -Exactly -Scope It

            }

            It 'throws error if version requirement not met' {
                $Script:ExternalVersion = '1.0'
                { New-PASAccountPassword -AccountID 12_3 } | Should -Throw
                $Script:ExternalVersion = '0.0'
            }

        }

        Context 'Response Output' {

            BeforeEach {

                Mock Invoke-PASRestMethod -MockWith {
                    [PSCustomObject]@{
                        'Password' = 'SomePassword'
                    }
                }

                $response = New-PASAccountPassword -AccountID 12_3

            }

            It 'provides output' {

                $response | Should -Not -BeNullOrEmpty

            }

            It 'has output with expected number of properties' {

                ($response | Get-Member -MemberType NoteProperty).length | Should -Be 1

            }

            It 'outputs object with expected typename' {

                $response | Get-Member | Select-Object -ExpandProperty typename -Unique | Should -Be psPAS.CyberArk.Vault.Credential

            }

        }

    }

}