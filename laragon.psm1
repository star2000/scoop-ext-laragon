if (!(Test-Path scoop)) {
    Write-Warning 'scoop is required.'
    Write-Warning 'Execute the following command to install.'
    Write-Warning 'iwr -useb get.scoop.sh | iex'
    exit
}

$LaragonHome = $env:LaragonHome
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
            Get-ChildItem $_.Root 'laragon.exe' -File -Recurse -ErrorAction SilentlyContinue
        } | Select-Object -First 1
    if ($laragon) {
        $LaragonHome = $laragon.Directory
    }
    else {
        Write-Warning 'Laragon is not installed.'
        exit
    }
}
[Environment]::SetEnvironmentVariable('LaragonHome', $LaragonHome, 'User')
}

function Get-ScoopAppName ([Parameter(Mandatory)] $Name) {
    $alias = @{
        'sublime'   = 'sublime-text'
        'code'      = 'vscode'
        'notepad++' = 'notepadplusplus'
        'mysql'     = 'mariadb'
    }
    if ($alias.ContainsKey($Name)) {
        return $alias.$Name
    }
    else {
        return $Name
    }
}

function Install-LaragonApp ([Parameter(Mandatory)] $Name) {
    scoop install (Get-ScoopAppName($Name))

    Remove-Item "$LaragonHome\bin\$Name" -Recurse -Force -ErrorAction Ignore

    $AppDir = scoop prefix (Get-ScoopAppName($Name))

    if ($Name -in 'apache', 'memcached', 'mongodb', 'mysql', 'nginx', 'nodejs', 'php', 'python', 'redis') {
        $AppDir = Split-Path $AppDir
    }

    New-Item "$LaragonHome\bin\$Name" -ItemType Junction -Value $AppDir
}

function Uninstall-LaragonApp ([Parameter(Mandatory)] $Name) {
    scoop uninstall (Get-ScoopAppName($Name))

    Remove-Item "$LaragonHome\bin\$Name" -Recurse -Force -ErrorAction Ignore
}
