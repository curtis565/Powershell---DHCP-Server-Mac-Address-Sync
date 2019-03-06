# Powershell---DHCP-Server-Mac-Address-Sync
Addresses the issue of Windows DHCP Server Not replicating Mac-Address Allow List for Failover Scopes

Powershell Script to Sync DHCP Mac Address filters between replicated DHCP servers. Windows in all of its mighty wisdom decided that scopes should be replicated, but MAC address filters should not be. Script uses simple array to compare in a Master/Slave configuration. Whatever machine you set as $MasterServerHostname will overwrite whatever is on $SlaveServerHostname. Script Should be run off the slave server.
