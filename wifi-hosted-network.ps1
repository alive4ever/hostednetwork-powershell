# Admin check
# Source http://blogs.technet.com/b/heyscriptingguy/archive/2011/05/11/check-for-admin-credentials-in-a-powershell-script.aspx
function getAdmin {
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`

        [Security.Principal.WindowsBuiltInRole] "Administrator")
}

# Get Admin rights
$admincheck = getAdmin
If ($admincheck -is [System.Management.Automation.PSCredential])
{

        Start-Process -FilePath PowerShell.exe -Credential $admincheck -ArgumentList $myinvocation.mycommand.definition

    Break

    }
# Error Admin
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`

    [Security.Principal.WindowsBuiltInRole] "Administrator"))

{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"

    return $false | Out-Null

}

# Driver check
Function DriverCheck {
	If
	(
	netsh wlan show drivers | Select-String "Hosted network supported  : Yes"
	)
	{	Write-Output "Your wireless card support Hosted Network" }
	 else 
	# Error Driver
	{	Write-Warning "Your wireless card doesn't support Hosted Network" | Out-Host }
		return $FALSE | Out-Null
}

DriverCheck

# Setting up SSID and passphrase
Function SetSSID
{
	Write-Output "Configuring wireless SSID and passphrase"
    if (Get-Variable "SSID" -Scope Script -ErrorAction SilentlyContinue) {
    Set-Variable -Name "SSID" -Value "$(Read-Host -Prompt 'Input your desired wireless SSID' )" -Scope Script
    } Else {
    New-Variable -Name "SSID" -Value "$(Read-Host -Prompt 'Input your desired wireless SSID' )" -Scope Script
    }
    if (Get-Variable "WPAKEY" -Scope Script -ErrorAction SilentlyContinue) {
    Set-Variable -name "WPAKEY" -Value $(Read-Host -Prompt 'Input your desired passphrase' -AsSecureString) -Scope Script
    } Else {
    New-Variable -name "WPAKEY" -Value $(Read-Host -Prompt 'Input your desired passphrase' -AsSecureString) -Scope Script
    }
}

# Error SSID
Function CheckSSID
{
	If ( ! "$SSID" -eq "$NUL" )
	{} Else {
        Write-Warning "You need to specify SSID for the Hosted Network"
        return $false | Out-Null
    }
}

Function DecryptWPAKEY
{
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($WPAKEY)
    $DecryptedWPAKEY = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    Write-Output $DecryptedWPAKEY
}

Function CheckWPAKEY
{
	If ( ! "$(DecryptWPAKEY)" -eq "$NUL" )
	{} Else {
		Write-Warning "You need to specify WPA Passphrase for the Hosted Network"
        Return $false | Out-Null
	}
    If ( ! "$(DecryptWPAKEY)".length -lt 8 )
    {} Else {
        Write-Warning "The passphrase need to be greater than eight characters"
        Return $false | Out-Null
    }
}

Function ConfigWLAN
{
    $MyWPAKey = "$(DecryptWPAKEY)"
    netsh wlan set hostednetwork mode=allow key="$MyWPAKey" keyUsage=persistent ssid="$SSID" | Out-Null
    if ($?) { Write-Output "The Hosted Network has been configured" | Out-Host }
    else { Write-Output "Hosted Network configuration failed!" | Out-Host }
}

Function StartWLAN
{
    if (netsh wlan start hostednetwork | Out-Host)
    { Write-Output "The Hosted Network has been started" | Out-Host }
}

Function StopWLAN
{
    if (netsh wlan stop hostednetwork | Out-Host)
    { Write-Output "The Hosted Network has been stopped" | Out-Host }
}

Function StatusWLAN
{
    netsh wlan show hostednetwork | Out-Host
}

Function Show-Menu
{
    param (
        [String]$Title = "Hosted Network Configuration"
    )
    Clear-Host
# Welcome message is shown on startup
Write-Output "Hosted Network Easy Setup"
"========================="
"Windows can act as a virtual wireless access point"
"to share your main internet connection with your mobile devices"
"Please be aware of your surrounding wireless signals, so that"
"you don't cause unwanted radio interferences for your neighbors"
"This script will help you configure Windows to act as wireless"
"access point"

Write-Host "1. Press 1 to set SSID and passphrase"
Write-Host "2. Press 2 to apply SSID and passphrase configuration"
Write-Host "3. Press 3 to start the hosted network"
Write-Host "4. Press 4 to show the hosted network status"
Write-Host "5. Press 5 to stop the hosted network"
Write-Host "Press q to exit"
}

do
{
    Show-Menu
    $choice = Read-Host "Make your selection"
    switch($choice)
    {
        '1' {
            If (DriverCheck) {
            SetSSID
            CheckSSID
            CheckWPAKEY
            }

        } '2' {
            
            if (CheckSSID) { Write-Output "SSID is OK" | Out-Host }
            
            if (CheckWPAKEY) { Write-Output "WPA Passphrase is OK" | Out-Host }
            if ($?) { ConfigWLAN | Out-Host }

        } '3' {
            If (DriverCheck) {
		    StartWLAN
	    }
        } '4' {
	    If (DriverCheck) {
		    StatusWLAN
	    }
	} '5' {
	    If (DriverCheck) {
		    StopWLAN
	    }

        } 'q' {
            Return
        }
    }
    Pause
}
# Keep showing menu until user press q
Until($choice -eq 'q')

