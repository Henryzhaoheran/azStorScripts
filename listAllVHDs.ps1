

# For ASM

Add-AzureAccount 
Select-AzureSubscription -SubscriptionId '' 
$disks = Get-AzureDisk
$disks | Where-Object {$_.AttachedTo -eq $null} | ft DiskName,IOType,Location,DiskSizeInGB,OS -AutoSize 



# For ARM

Login-AzureRmAccount  
Select-AzureRmSubscription -SubscriptionId "" 

$accountlist = Get-AzureRmStorageAccount

ForEach ($acc in $accountlist)
{
    $context = $acc.Context
    $containerList = Get-AzureStorageContainer -Context $context
    
    ForEach ($con in $containerlist.Name)
    {
        $token = $null
        do
        {
            $blobs = Get-AzureStorageBlob -Container $con -Context $context -ContinuationToken $token -MaxCount 1000 | where {($_.Name.EndsWith(".vhd")) -or ($_.Name.EndsWith(".VHD"))}
            if($Blobs.Length -le 0) { Break;}
            ForEach ($vhd in $blobs)
            {
                <#
                Uncomment this part if you want to see all disks and attached VM
                $($vhd.ICloudBlob.Container.Uri.AbsoluteUri) + $($vhd.Name) +"                   " + $vhd.ICloudBlob.Metadata["MicrosoftAzureCompute_VMName"]

                #>

                if($vhd.ICloudBlob.Metadata["MicrosoftAzureCompute_VMName"] -eq $null)
                {
                    "$($vhd.ICloudBlob.Container.Uri.AbsoluteUri) $($vhd.Name)                    Lease Status: $($vhd.ICloudBlob.Properties.LeaseStatus)"
                }

            }
            $Token = $blobs[$blobs.Count -1].ContinuationToken;

        }
        While ($token -ne $null)
        
    }

}