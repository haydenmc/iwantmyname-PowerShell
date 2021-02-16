# iwantmyname PowerShell
A PowerShell script for updating DNS records on iwantmyname.com based on the IP address assigned to a particular network adapter on the machine.

Typical use case is to update a DNS record for a particular domain to point to a server with a dynamically assigned IP address.

## Usage
### IPv4
```powershell
PS > .\Update-DnsRecord.ps1 -InterfaceAlias YOURADAPTERNAME -AddressFamily IPv4 -Username YOURUSERNAME -Password YOURPASSWORD -Hostname YOURHOSTNAME.COM -RecordType A
```

### IPv6
```powershell
PS > .\Update-DnsRecord.ps1 -InterfaceAlias YOURADAPTERNAME -AddressFamily IPv6 -Username YOURUSERNAME -Password YOURPASSWORD -Hostname YOURHOSTNAME.COM -RecordType AAAA
```

## Notes
This uses the only DNS API provided by iwantmyname, find the documentation for it [here](https://iwantmyname.com/developer/domain-dns-api).

It would be *awesome* if they provided an API that used API keys or something instead of basic auth with your account username and password.
But oh well. I guess this is what we have to work with.

### To add a scheduled task:
Simply open `taskschd.msc` and add a task to launch a program with the following:
- File: `powershell.exe`
- Arguments: `-ExecutionPolicy Bypass -File C:\Path\To\Update-DnsRecord.ps1 -AddressFamily IPv6 -InterfaceAlias "Your Network Interface" -Hostname "your.domain.here" -RecordType "AAAA" -Username "your@username.com" -Password "hunter2"`