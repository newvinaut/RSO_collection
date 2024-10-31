[CmdletBinding()]
param()
process {
    # Grab user profile paths
    $UserPaths = (Get-WmiObject win32_userprofile | Where-Object localpath -notmatch 'C:\\Windows').localpath
    # For each user profile
    foreach ($Path in $UserPaths) {
        # Check for Edge and Chrome
        $MSEdgeDir = $Path + '\AppData\Local\Microsoft\Edge\User Data'
        $GoogDir = $Path + '\AppData\Local\Google\Chrome\User Data'
        $CheckBrowserDir = New-Object Collections.Generic.List[string]
        if (Test-Path $MSEdgeDir) {
            $CheckBrowserDir.Add($MSEdgeDir)
        }
        if (Test-Path $GoogDir) {
            $CheckBrowserDir.Add($GoogDir)
        }
        # For each browser found
        foreach ($BrowserDir in $CheckBrowserDir) {
            # Grab browser profiles
            $ProfilePaths = (Get-ChildItem -Path $BrowserDir | Where-Object Name -match 'Default|Profile').FullName
            # For each browser profile
            foreach ($ProfilePath in $ProfilePaths) {
                $ExtPath = $ProfilePath + '\Extensions'
                if (Test-Path $ExtPath) {
                    # Store variables for output (blegh I'm bad at Powershell)
                    $BrowserProfileName = ($ProfilePath | Split-Path -Leaf)
                    $Application = ($ProfilePath | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf)
                    $Username = ($ProfilePath | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf)
                    # Get extension folders
                    $ExtFolders = Get-Childitem $ExtPath | Where-Object Name -ne 'Temp'
                    foreach ($Folder in $ExtFolders) {
                        # Extension version folders
                        $VerFolders = Get-Childitem $Folder.FullName
                        foreach ($Version in $VerFolders) {
                            # Check for json manifest
                            if (Test-Path -Path ($Version.FullName + '\manifest.json')) {
                                $Manifest = Get-Content ($Version.FullName + '\manifest.json') | ConvertFrom-Json
                                # If extension name looks like an App name
                                if ($Manifest.name -like '__MSG*') {
                                    $AppId = ($Manifest.name -replace '__MSG_', '').Trim('_')
                                    # Check locales folders for additional json
                                    @('\_locales\en_US\', '\_locales\en\') | ForEach-Object {
                                        if (Test-Path -Path ($Version.Fullname + $_ + 'messages.json')) {
                                            $AppManifest = Get-Content ($Version.Fullname + $_ +
                                                'messages.json') | ConvertFrom-Json
                                            # Check json for potential app names and save the first one found
                                            @($AppManifest.appName.message, $AppManifest.extName.message,
                                                $AppManifest.extensionName.message, $AppManifest.app_name.message,
                                                $AppManifest.application_title.message, $AppManifest.$AppId.message) |
                                            ForEach-Object {
                                                if (($_) -and (-not($ExtName))) {
                                                    $ExtName = $_
                                                }
                                            }
                                        }
                                    }
                                }
                                else {
                                    # Capture extension name
                                    $ExtName = $Manifest.name
                                }
                                # Output formatted string
                                Write-Output ($Username + ": " + $Application + ": " + $BrowserProfileName + ": " + [string] $ExtName +
                                    " v" + $Manifest.version + " (" + $Folder.name + ")")
                                # Reset extension name for next lookup
                                if ($ExtName) {
                                    Remove-Variable -Name ExtName
                                }
                            }
                        }
                    }
                }
#                 else {
#                     Write-Output 'No Extension folder found in' $ExtPath
#                 }
            }

        }
    }
}
