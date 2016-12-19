# List all P30 Disks in one subscription.
# All SSDs whose size is greater than 512GB is count as P30 disk. 

# For ASM

Add-AzureAccount 
Select-AzureSubscription -SubscriptionId '' 

$disks = Get-AzureDisk
$disks | Where-Object {($_.IOType -eq 'Provisioned') -and ($_.DiskSizeInGB -gt '512')} | ft DiskSizeInGB, MediaLink -AutoSize


# for ARM

Login-AzureRmAccount  
Select-AzureRmSubscription -SubscriptionId "" 

$accountlist = Get-AzureRmStorageAccount | Where {$_.Sku.Name -eq 'PremiumLRS'}

ForEach ($acc in $accountlist)
{
    $context = $acc.Context
    $containerList = Get-AzureStorageContainer -Context $context
    ForEach ($con in $containerlist.Name)
    {
        $blobs = Get-AzureStorageBlob -Container $con -Context $context | where {($_.Name.EndsWith(".vhd")) -or ($_.Name.EndsWith(".VHD"))}
        ForEach ($vhd in $blobs)
        {
            if($vhd.Length -gt '549755814400')
            {
                
                "$($vhd.Name)         Disk Size: $($vhd.Length)             Attach To VM: $($vhd.ICloudBlob.Metadata["MicrosoftAzureCompute_VMName"])                      URI: $($vhd.ICloudBlob.Container.Uri.AbsoluteUri)"
            }

        }
        
    }    

}