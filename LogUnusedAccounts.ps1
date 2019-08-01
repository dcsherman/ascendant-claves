## Set a variable to flag the logging or the removal function
$remove_users_found = $false

## Set today's date as a constant variable to avoid invoking Get-Date cmdlet for each instance.
$today_object = Get-Date

## Format the date to write a string to the log
$today_string = get-date -Format 'MM-dd-yyyy hh:mm tt'

## Create the Where-Object scriptblock ahead of time for ease of use
$unused_conditions_met = {
    ## Ensure built-in AD user objects are left intact
    !$_.isCriticalSystemObject -and
    ## The account is disabled (account cannot be used)
    (!$_.Enabled -or
    ## The password is expired (account cannot be used)
    $_.PasswordExpired -or
    ## The account has never been used
    !$_.LastLogonDate -or
    ## The account hasn't been used for 60 days
    ($_.LastLogonDate.AddDays(60) -lt $today_object))
}

## Query all Active Directory user accounts for defined conditions
$unused_accounts = Get-ADUser -Filter * -Properties passwordexpired,lastlogondate,isCriticalSystemobject | Where-Object $unused_conditions_met |
    Select-Object @{Name='Username';Expression={$_.samAccountName}},
        @{Name='FirstName';Expression={$_.givenName}},
        @{Name='LastName';Expression={$_.surName}},
        @{Name='Enabled';Expression={$_.Enabled}},
        @{Name='PasswordExpired';Expression={$_.PasswordExpired}},
        @{Name='LastLoggedOnDaysAgo';Expression={if (!$_.LastLogonDate) { 'Never' } else { ($today_object - $_.LastLogonDate).Days}}},
        @{Name='Operation';Expression={'Found'}},
        @{Name='On';Expression={$today_string}}

## Write results to log file
$unused_accounts | Export-Csv -Path unused_user_accounts.csv -NoTypeInformation

## If set to true, remove derelict accounts and append to the log
if ($remove_users_found) {
    foreach ($account in $unused_accounts) {
        Remove-ADUser $account.Username -Confirm:$false
        Add-Content -Value "$($account.UserName),,,,,,Removed,$today_string" -Path unused_user_accounts.csv
    }
}