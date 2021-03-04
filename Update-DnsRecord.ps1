<#
    A PowerShell script to update a DNS record on IWantMyName
    Using an IP address from a network adapter with a given alias
#>

param(
    # The alias for the interface to get the IP address from
    [Parameter(Mandatory = $true)]
    [string]
    $InterfaceAlias,
    # The address family to retrieve (IPv4, IPv6)
    [Parameter(Mandatory = $true)]
    [ValidateSet("IPv4", "IPv6")]
    [string]
    $AddressFamily = "IPv4",
    # The username for iwantmyname
    [Parameter(Mandatory = $true)]
    [string]
    $Username,
    # The password for iwantmyname
    [Parameter(Mandatory = $true)]
    [string]
    $Password,
    # Hostname to update records for
    [Parameter(Mandatory = $true)]
    [string]
    $Hostname,
    # Record type to update
    [Parameter(Mandatory = $true)]
    [string]
    $RecordType = "A"
)

# Constants
$ApiUri = "https://iwantmyname.com/basicauth/ddns"

# Fetch the IP from the given adapter
$IpAddress = Get-NetIPAddress |`
    Where-Object InterfaceAlias -ieq $InterfaceAlias |`
    Where-Object AddressFamily -ieq $AddressFamily |`
    Where-Object AddressState -ieq "Preferred" |`
    Where-Object PrefixOrigin -ine "WellKnown" |` # Filter reserved addresses
    Where-Object SuffixOrigin -ine "Link" |` # Filter link-local addresses
    Select-Object -Index 0 |`
    Select-Object -ExpandProperty "IPAddress"

# Make cred
$securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

# Construct body
$body = "hostname=$Hostname&type=$RecordType&value=$IpAddress"

# Send request (this should throw on a non-success case)
Write-Host -ForegroundColor Cyan "Setting '$RecordType' on '$Hostname' to '$IpAddress' ..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$request = Invoke-WebRequest -Method "POST" -Credential $cred -Uri $ApiUri -Body $body -UseBasicParsing -ErrorAction Stop
Write-Host -ForegroundColor Green "$($request.StatusCode) $($request.StatusMessage)"
Write-Host $(([char[]]$request.Content) -join "")
