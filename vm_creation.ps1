# Read Jenkins environment variables
$vcenter = $env:vcenter
$vm_count = [int]$env:vm_count
$Datastore = $env:Datastore
$Folder = $env:Folder
$Cluster = $env:Cluster
$VM_prefix = $env:VM_prefix
$VM_from_template = $env:VM_from_template
$VM_power_on = [bool]$env:VM_power_on
$resourcePool = $env:resourcePool
$numcpu = [int]$env:numcpu
$MBram = [int]$env:MBram
$MBguestdisk = [int]$env:MBguestdisk
$Typeguestdisk = $env:Typeguestdisk
$guestOS = $env:guestOS


$vcenteruser = “cloudadmin@vmc.local“
$vcenterpw = “v+6tz*v9AUQzIZE“

# Load PowerCLI
Import-Module VMware.PowerCLI
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

# Connect to vCenter
Connect-VIServer -Server $vcenter -User $vcenteruser -Password $vcenterpw | Out-Null

# Get resource pool
$rp = Get-ResourcePool -Name $resourcePool -ErrorAction Stop

# Create VMs
1..$vm_count | ForEach-Object {
    $VM_postfix = "{0:D2}" -f $_
    $VM_name = "$VM_prefix$VM_postfix"

    if ([string]::IsNullOrEmpty($VM_from_template)) {
        Write-Host "Creating new VM: $VM_name" -ForegroundColor Green
        New-VM -Name $VM_name `
               -ResourcePool $rp `
               -NumCPU $numcpu `
               -MemoryMB $MBram `
               -DiskMB $MBguestdisk `
               -DiskStorageFormat $Typeguestdisk `
               -Datastore $Datastore `
               -GuestId $guestOS `
               -Location $Folder
    } else {
        Write-Host "Deploying VM from template: $VM_name" -ForegroundColor Green
        New-VM -Name $VM_name `
               -Template $VM_from_template `
               -ResourcePool $rp `
               -Datastore $Datastore `
               -Location $Folder
    }

    if ($VM_power_on) {
        Write-Host "Powering on VM: $VM_name" -ForegroundColor Yellow
        Start-VM -VM $VM_name -Confirm:$false
    }
}

# Disconnect
Disconnect-VIServer -Server $vcenter -Confirm:$false | Out-Null
Write-Host "VM deployment completed." -ForegroundColor Cyan
