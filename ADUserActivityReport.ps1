#Requires -Module ActiveDirectory

<#	
	Produces, emails list of users' login/logout times on all computers in an Active Directory organizational unit, with appropriate audit policies to display event IDs.
#>

[CmdletBinding()]
[OutputType()]
param
(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[ValidatePattern('^OU\=')]
	[string]$OrganizationalUnit,

	[Parameter()]
	[string[]]$EventId = @(4647,4648),

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$EmailToAddress,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$EmailFromAddress = 'IT Administrator',
	
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$EmailSubject = 'User Activity Report'

)
process {
	try
	{
#region Gather all applicable computers
		$Computers = Get-ADComputer -SearchBase $OrganizationalUnit -Filter * | Select-Object Name
		if (-not $Computers)
		{
			throw "No computers found in OU [$($OrganizationalUnit)]"
		}
#endregion
		
#region Build XPath filter
		$XPathElements = @()
		foreach ($id in $EventId)
		{
			$XPathElements += "Event[System[EventID='$Id']]"
		}
		$EventFilterXPath = $XPathElements -join ' or '
#endregion
		
#region Build the array that will display the information we want
		$LogonId = $EventId[1]
		$LogoffId = $EventId[0]
		
		$SelectOuput = @(
		@{ n = 'ComputerName'; e = { $_.MachineName } },
		@{
			n = 'Event'; e = {
				if ($_.Id -eq $LogonId)
				{
					'Logon'
				}
				else
				{
					'LogOff'
				}
			}
		},
		@{ n = 'Time'; e = { $_.TimeCreated } },
		@{
			n = 'Account'; e = {
				if ($_.Id -eq $LogonId)
				{
					$i = 1
				}
				else
				{
					$i = 3
				}
				[regex]::Matches($_.Message, 'Account Name:\s+(.*)\n').Groups[$i].Value.Trim()
			}
		}
		)
#endregion
		
#region Query the computers' event logs and send output to a file to email
		$TempFile = 'C:\useractivity.txt'
		foreach ($Computer in $Computers) {
	    	Get-WinEvent -ComputerName $Computer -LogName Security -FilterXPath $EventFilterXPath | Select-Object $SelectOuput | Out-File $TempFile
		}
#endregion
		
		$emailParams = @{
			'To' = $EmailToAddress
			'From' = $EmailFromAddress
			'Subject' = $EmailSubject
			'Attachments' = $TempFile
		}
		
		Send-MailMessage @emailParams

	} catch {
		Write-Error $_.Exception.Message
	}
	finally
	{
## Cleanup the temporary file generated	
		Remove-Item -Path $TempFile -Force -ErrorAction SilentlyContinue
	}
}