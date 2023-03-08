<# Non-interactive entry
$ipAddresses = @("205.156.141.241", "167.245.92.242", "8.8.8.8")
#>
# Only works for RIPE Regional
# Interactive entry
Write-Host "Please enter a list of IP addresses separated by a comma: "
$ipAddresses = Read-Host
$ipAddresses = $ipAddresses -split ","

Function Get-ASN {
    Param ($ipAddress)

    $url = "https://stat.ripe.net/data/network-info/data.json?resource=$ipAddress"
    $response = Invoke-WebRequest -Uri $url

    If ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        return $data.data.asns[0]
    }
    else {
        return $null
    }
}

Function Get-CompanyName {
    Param ($asn)

    $url = "https://stat.ripe.net/data/as-overview/data.json?resource=$asn"
    $response = Invoke-WebRequest -Uri $url

    If ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        return $data.data.holder
    }
    else {
        return $null
    }
}

Foreach ($ipAddress in $ipAddresses) {
    $asn = Get-ASN $ipAddress
    If ($asn -ne $null) {
        $companyName = Get-CompanyName $asn
        Write-Host "$ipAddress belongs to $companyName"
    }
    else {
        Write-Host "$ipAddress is not associated with an ASN"
    }
}
