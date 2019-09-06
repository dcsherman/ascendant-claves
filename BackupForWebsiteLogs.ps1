function Backup-IISLogs() {
Param(
# Source location folder for logs we wish to backup
[parameter(Mandatory = $true)]
[ValidateNotNullOrEmpty()]
[string]$IISLogsDir
)
# This function will backup IIS log Files
Import-Module PSCX
# Name our zip file
$zipFileName = "IIS_LOGS_$(Get-Date -f yyyy-MM-dd)" + '.zip'
# Email settings
$sendEmailSMPTServer = 'my.mail.server.com'
$sendEmailFrom = 'alexander.nevermind@nunya.biz'
$sendEmailTo = 'alexander.nevermind@nunya.biz'
$subjectSuccess = 'IIS logs backed up successfully'
$bodySuccess = 'The IIS logs were backed up successfully'
$subjectFailure = 'IIS logs failed to backup'
$bodyFailure = 'The IIS logs failed to backup'
try
{
# Sets the current working location to the specified location
Set-Location $IISLogsDir
# Loop through all the files (not folders) in the folder and add them to a zip file
Invoke-Command -ScriptBlock { Get-ChildItem $IISLogsDir -Recurse -File | where-object { -not ($_.psiscontainer)} |
Write-Zip -OutputPath $zipFileName
} -ArgumentList $zipFileName
# Check for errors
if ($?)
{
# Send an email with success message
Send-Mail -smtpServer $sendEmailSMPTServer -from $sendEmailFrom -to $sendEmailTo -subject $subjectSuccess -body $bodySuccess
}
else
{
# Send an email with failure message
Send-Mail -smtpServer $sendEmailSMPTServer -from $sendEmailFrom -to $sendEmailTo -subject $subjectFailure -body $bodyFailure
}
}
# Catch exceptions
catch {
Write-Host "System.Exception on:- $(Get-date) - $($Error[0].Exception.Message)"
}
finally
{
Write-Host "Backup-IISLogs finished at:- $(Get-date)"
}
}
#region Send-Mail
function Send-Mail{
param($smtpServer,$from,$to,$subject,$body)
$smtp = new-object system.net.mail.smtpClient($SmtpServer)
$mail = new-object System.Net.Mail.MailMessage
$mail.from = $from
$mail.to.add($to)
$mail.subject = $subject
$mail.body = $body
$smtp.send($mail)
}
#endregion
# Test our function using  a supplied directory
$sourceDir = 'C:\inetpub\logs\logfiles'
Backup-IISLogs $sourceDir

In the script we just saw, we start off with one parameter called $IISLogsDir. We have marked the parameter as mandatory and we have validation to make sure the parameter cannot be Null or Empty by using:

ValidateNotNullOrEmpty.
Param(
    # Source location folder for logs we wish to backup
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$IISLogsDir
  )

try
  {       
   
    ...
  }
 
  # Catch exceptions   
  catch {
    Write-Host "System.Exception on:- $(Get-date) - $($Error[0].Exception.Message)"
  }
  finally
  {
    Write-Host "Backup-IISLogs finished at:- $(Get-date)"
  }  
}

function Send-Mail{
  param($smtpServer,$from,$to,$subject,$body)
 
...
}

