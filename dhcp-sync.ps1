$MasterServerHostname = "testserver1.contoso.com";

# Get the REMOTE filters from $MasterServerHostname
$MasterFilterAdd = invoke-command -computername $MasterServerHostname { Get-DhcpServerv4Filter }

# Backup Mac Filter of Master 
$MasterFilterAdd | Export-Csv C:\Scripts\dhcp_sync_mac_filter\dhcp_sync_mac_filter.txt

# Get the Current machine (Slave) MAC Adddress Filters
$SlaveFilterAdd = Get-DhcpServerv4Filter


if ($SlaveFilterAdd -eq $null)
{
    ForEach ($AttributeAdd in $MasterFilterAdd) {
        write-host $AttributeAdd.List
        write-host $AttributeAdd.MacAddress;
        write-host $AttributeAdd.Description
        Add-DhcpServerv4Filter -List $AttributeAdd.List -MacAddress $AttributeAdd.MacAddress -Description $AttributeAdd.Description
    }
}
else
{
    $ResolvedFilterAdd = Compare-Object $MasterFilterAdd $SlaveFilterAdd -Property MacAddress -PassThru

     # Import the new Filter Set
    ForEach ($AttributeAdd in $ResolvedFilterAdd) {
        write-host $AttributeAdd.List
        write-host $AttributeAdd.MacAddress;
        write-host $AttributeAdd.Description
        Add-DhcpServerv4Filter -List $AttributeAdd.List -MacAddress $AttributeAdd.MacAddress -Description $AttributeAdd.Description
    }
}
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Start-Sleep -s 5
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Part 2: Remove entries not on Master list
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Get the REMOTE filters from $MasterServerHostname
$MasterFilterRemove = invoke-command -computername $MasterServerHostname { Get-DhcpServerv4Filter }

# Get the LOCAL filters from localhost
$SlaveFilterRemove = Get-DhcpServerv4Filter

# Compare SlaveFilter against Masterfilter to show diffrence between MAC's
$ResolvedFilterRemove = Compare-Object $SlaveFilterRemove $MasterFilterRemove -Property MacAddress -PassThru 

# Remove Mac Addresses in ResolvedFilter
ForEach ($AttributeRemove in $ResolvedFilterRemove) {
    write-host $AttributeRemove.MacAddress
    Remove-DhcpServerv4Filter $AttributeRemove.MacAddress 
}

#Update Scopes from HQAPPDHCP3 to AFICAPPDHCP3
Invoke-DhcpServerv4FailoverReplication -Computername $MasterServerHostname -force

#exit 4
