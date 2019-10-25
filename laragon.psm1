if (!(Test-Path scoop)) {
    Write-Warning 'scoop is required.'
    Write-Warning 'Execute the following command to install.'
    Write-Warning 'iwr -useb get.scoop.sh | iex'
    exit
}

$LaragonHome = $env:LARAGON_HOME
if (!$LaragonHome) {
    $UninstallPaths = @(
        'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
        'HKCU:Software\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    if ([IntPtr]::Size -eq 8) {
        $UninstallPaths += 'HKLM:SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    }

    $laragon = Get-ChildItem $UninstallPaths | Where-Object { $_.Name -like '*laragon*' }
    if ($laragon) {
        $LaragonHome = $laragon.GetValue('InstallLocation')
    }
    else {
        $laragon = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
            Get-ChildItem $_.Root 'laragon.exe' -File -Recurse -ErrorAction Ignore
        } | Select-Object -First 1
    if ($laragon) {
        $LaragonHome = $laragon.Directory
    }
    else {
        Write-Warning 'Laragon is not installed.'
        exit
    }
}
[Environment]::SetEnvironmentVariable('LARAGON_HOME', $LaragonHome, 'User')
}

function Get-LaragonAlias ([Parameter(Mandatory)] $Name) {
    $Name = ($Name -split '@')[0]
    $Name = ($Name -split '-')[0]
    $Name = $Name -replace '\d*$'

    $Alias = @{
        'vscode'          = 'code'
        'vscodium'        = 'code'
        'notepadplusplus' = 'notepad++'
        'mariadb'         = 'mysql'
    }
    if ($Alias.ContainsKey($Name)) {
        return $Alias.$Name
    }
    else {
        return $Name
    }
}

function Get-ScoopAlias ([Parameter(Mandatory)] $Name) {
    $App, $Version = $Name -split '@'
    $Alias = @{
        'sublime'   = 'sublime-text'
        'code'      = 'vscode'
        'notepad++' = 'notepadplusplus'
    }
    if ($Alias.ContainsKey($App)) {
        if ($Version) {
            return $Alias.$App, $Version -join '@'
        }
        else {
            return $Alias.$App
        }
    }
    else {
        return $Name
    }
}

function Install-LaragonApp ([Parameter(Mandatory)] $Name) {
    $ScoopApp = Get-ScoopAlias $Name
    $LaragonApp = Get-LaragonAlias $Name

    scoop install $ScoopApp
    $AppDir = scoop prefix ($ScoopApp -split '@')[0]

    if ($LaragonApp -in 'apache', 'memcached', 'mongodb', 'mysql', 'nginx', 'nodejs', 'php', 'python', 'redis') {
        $AppDir = Split-Path $AppDir
    }

    Remove-Item "$LaragonHome\bin\$LaragonApp" -Recurse -Force -ErrorAction Ignore

    New-Item "$LaragonHome\bin\$LaragonApp" -ItemType Junction -Value $AppDir
}

function Uninstall-LaragonApp ([Parameter(Mandatory)] $Name) {
    $ScoopApp = Get-ScoopAlias $Name
    $LaragonApp = Get-LaragonAlias $Name

    scoop uninstall $ScoopApp

    Remove-Item "$LaragonHome\bin\$LaragonApp" -Recurse -Force -ErrorAction Ignore
}

New-Alias inla Install-LaragonApp
New-Alias unla Uninstall-LaragonApp
