
param (
    [string]$vcenter,
    [int]$vm_count,
    [string]$Datastore,
    [string]$Folder,
    [string]$Cluster,
    [string]$VM_prefix,
    [string]$VM_from_template,
    [string]$resourcePool,
    [bool]$VM_power_on,
    [int]$numcpu,
    [int]$MBram,
    [int]$MBguestdisk,
    [int]$guestOS

)

# Start of script parameters section
#
# vCenter Server configuration

$vcenteruser = “cloudadmin@vmc.local“
$vcenterpw = “v+6tz*v9AUQzIZE“


# Specify the VM provisioning type (sync/async) - true = async (parallel), false = sync (sequentional)
$VM_create_async = $false
#

clear-host

$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
#
# Connect to vCenter Server
write-host “Connecting to vCenter Server $vcenter” -foreground green
$vc = connect-viserver $vcenter -User $vcenteruser -Password $vcenterpw
#

#$O_cluster=Get-Cluster $Cluster

1..$vm_count | foreach {
  $VM_postfix=”{0:D2}” -f $_
  $VM_name= $VM_prefix + $VM_postfix
  #$O_ESXi=Get-Cluster $Cluster_name | Get-VMHost -state connected | Get-Random

  if ($VM_from_template -eq "") {
    write-host “Creation of VM $VM_name initiated”  -foreground green
    New-VM -RunAsync:$VM_create_async -Name $VM_Name -ResourcePool $resourcePool -numcpu $numcpu -MemoryMB $MBram -DiskMB $MBguestdisk -DiskStorageFormat $Typeguestdisk -Datastore $Datastore -GuestId $guestOS -Location $Folder
  } else {
    write-host “Deployment of VM $VM_name from template $VM_from_template initiated”  -foreground green
    New-VM -RunAsync:$VM_create_async -Name $VM_Name -Template $VM_from_template -ResourcePool $resourcePool -Datastore $Datastore -Location $Folder
  }

  if ($VM_power_on) {
    write-host “Power On of the  VM $VM_name initiated" -foreground green
    Start-VM -VM $VM_name -confirm:$false -RunAsync
  }
}
