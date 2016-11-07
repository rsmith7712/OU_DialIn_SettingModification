<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.127
	 Created on:   	6/13/2016 9:40 AM
	 Created by:   	Richard Smith
	 Organization: 	
	 Filename:     	OU_DialIn_SettingModification.ps1
	===========================================================================
	.DESCRIPTION
		# 1. Query ADUsers in a specific OU  
		# 2. Set the Network Access Permissions to 'Control access through NPS Network Policy' under the Dial-in tab
		# 3. Make a note in the user's Description field that the 'Dial-in settings changed as of yyyy/mm/dd' 
		# 4. Export results to a .CSV file of accounts affected
#>

# Import Modules Needed
Import-Module ActiveDirectory

# Output results to CSV file
$LogFile = "C:\OU_Acts_Modified.csv"

# Today's Date
$today = get-date -uformat "%Y/%m/%d"

# Date to search by
$xDays = (get-date).AddDays(-1)

# Date disabled description variable
$userDesc = "Dial-in Settings Updated on:" + " - " + $today 

# Sets the OU to do the base search for all user accounts, change as required
#$SearchBase = "OU=Ticket, OU=Service Accounts, OU=Domain Services, DC=DOMAIN, DC=com"
$SearchBase = "OU=Laptop, OU=IS, OU=Corporate Computers, DC=DOMAIN, DC=com"

# Pull all inactive users older than $xDays from a specified OU
$Users = Get-ADUser -SearchBase $SearchBase -Properties PasswordNeverExpires, LastLogonDate -Filter {
    (LastLogonDate -le $xDays)
    -AND (Enabled -eq $True)
} |  ForEach-Object {
    # To set Dial-in = DENY
    #Set-ADUser $_ -Replace @{msNPAllowDialIn=$FALSE} -WhatIf 
    
    # To set Dial-in = Control Access Through NPS Network Policy
    Set-ADUser $_ -Clear msNPAllowDialIn;
   
    #Set-ADUser $_ -AccountExpirationDate $today -Description $userdesc 
    $_ | select Name, SamAccountName, PasswordNeverExpires, LastLogonDate
}

$Users | Where-Object {$_} | Export-Csv $LogFile -NoTypeInformation 
 
#start $LogFile 