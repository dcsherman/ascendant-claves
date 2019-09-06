# ascendant-claves
library of PowerShell scripts to facilitate network maintenance

    ADUserActivityReport
    Produces, emails list of users' login/logout times on all computers in an Active Directory organizational unit, with appropriate audit policies to display event IDs.
	
	LogUnusedAccounts
	Scroll through all non-AD users on the OU, mark the expired, disabled and disused accounts. Log the accounts for review or removal.
	
	DHCPSurvey
	A script to report leases and scopes for all active DHCP servers in Active Directory, all scopes on all DHCP servers and outputs all leases in all of those scopes.
	
	ScanForShares
	A script to scan selected Windows Servers from Active Directory and discover their shared volumes using Windows Management Instrumentation ("WMI") extensions.
	
	RuntimeReports
	Reads through event logs at each node to determine the start-up and shutdown times for each computer. From these values, the total downtime for each computer may be calculated.
	
	ReportOldComputers
	Sorts through computers found in Active Directory, lists them according to active DNS records and online/offline status
	
	PreScavengeProcess
	This script will report on all dynamic DNS records in a particular AD-integrated DNS zone that
	are at risk of being scavenged by the DNS scavenging process. (Ex. ">Get-RecordsToBeScavenged.ps1 -DnsZone myzone -WarningDays 5" will find all DNS records in the zone 'myzone' that are set to be scavenged within 5 days.
	
	BackupForWebsiteLogs
	Function for backing up performance and activity logs for resident IIS web server.

