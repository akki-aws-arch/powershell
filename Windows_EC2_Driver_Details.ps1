#PowerShell Script to fetch Network Adapter Details from Windows Server
#$ErrorActionPreference=“silentlycontinue”
$a=@(Get-Content "Path to input file")  #Reading servers list from Text file that will be fetched in adavance ussign AWS CLI
$creds=Get-Credential
$netInfo_arr=@() #Array Initialization to store PS Custom Object $netinfo
foreach($server in $a)
{
    if((Test-Connection -ComputerName $server -Quiet) -eq 'True') #Checking the connection using ICMP
    {
        $DriverInfo=Invoke-Command -ComputerName $server -Credential $creds -ScriptBlock{Get-WmiObject Win32_PnPSignedDriver| Select DeviceName, Manufacturer, DriverVersion |Where{$_.DeviceName -clike "*PV*" -or $_.DeviceName -clike "Amazon Elastic Network Adapter" -or $_.DeviceName -clike "Intel*"}}
        #Setting Note Property to attach to Custom Object
        $Output=@{
                    "ServerName"=(@($DriverInfo.PSComputerName) | Out-String).Trim();
                    "DriverName"=(@($DriverInfo.DeviceName) | Out-String).Trim();
                    "DriverVendor"=(@($DriverInfo.Manufacturer) | Out-String).Trim();
                    "DriverVersion"=(@($DriverInfo.DriverVersion) | Out-String).Trim()
                 }
        $netInfo = New-Object -TypeName psobject -Property $Output #Creating Custom Object
        $netInfo_arr += $netInfo #Adding Custom Object to Array
     }
    else
    {
        $server | Out-File 'Path to Output text file'  -Append  #If connection to an Instances is failed the store it in this file
    }
    $netInfo_arr | Select -Property ServerName,DriverName,DriverVendor, DriverVersion | Export-Csv 'Path to Output CSV file' -NoTypeInformation   #Exporting the result to CSV in desired format
  
}
