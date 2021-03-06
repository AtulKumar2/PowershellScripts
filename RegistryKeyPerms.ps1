$Script:Modifiable = 0
$Script:NonModifiable = 0
$Script:LogFolder="TestLogs"
$Script:LogFile="RegistryHivePermsLog.txt"
$Script:LogFilePath=(".\"+$Script:LogFile)
$Script:KeyNameFile="RegistryKeyList.txt"
$Script:KeyNameFilePath=(".\"+$Script:KeyNameFile)


function MakeFiles
{
    $SysDrive = get-item env:SystemDrive
    cd ($SysDrive.Value+"\")
    #Test-Path can also be used to check existence of file
    if (!(get-item ($SysDrive.Value+"\"+$Script:LogFolder+"\")))
    {
        new-item -path ($SysDrive.Value+"\") -name "TestLogs" -type directory
    }
    if (!(get-item ($SysDrive.Value+"\"+$Script:LogFolder+"\"+$Script:LogFile)))
    {
        new-item -path ($SysDrive.Value+"\"+$Script:LogFolder+"\") -name $Script:LogFile -type file
    }
    if ((get-item ($SysDrive.Value+"\"+$Script:LogFolder+"\"+$Script:LogFile)))
    {
        $Script:LogFilePath=($SysDrive.Value+"\"+$Script:LogFolder+"\"+$Script:LogFile)
    }
    
    # Create Key test file
    
}

function AddToLog
{
    param ($message)
    echo $message
    out-file -FilePath $Script:LogFilePath -Encoding default -Append -Inputobject $message
}

 
@'
Queryvalues 		1                             1
setvalue 		    2                            10
createsubkey 		4                           100
enumeratesubkeys 	8                          1000
notify  		    16                        10000
createlink  		32 	                     100000	
delete 		        65536         10000000000000000
readpermissions 	131072       100000000000000000
changepermissions  	262144	    1000000000000000000
takeownership 		524288     10000000000000000000

Fullcontrol  		983103     11110000000000111111
executekey 	        131097       100000000000011001
readkey 		    131097       100000000000011001
writekey		    131078       100000000000000110 
'@ > $null

function CheckModifyAccess
{
    param ($AccessObject, [ref]$ModifyRights)
        
    $RightsList = $AccessObject.RegistryRights
    $ModifyBits= [System.Security.AccessControl.RegistryRights]::SetValue`
            -bor [System.Security.AccessControl.RegistryRights]::CreateSubKey`
            -bor [System.Security.AccessControl.RegistryRights]::CreateLink`
            -bor [System.Security.AccessControl.RegistryRights]::Delete`
            -bor [System.Security.AccessControl.RegistryRights]::ChangePermissions`
            -bor [System.Security.AccessControl.RegistryRights]::TakeOwnership
    if ($RightsList -band $ModifyBits) { $ModifyRights.Value = 1 }
}

Function ProcessKey
{
    param ($HiveRoot, $KeyFullPath)
        
    cd ($HiveRoot+":")
    $AccessObject = (Get-Acl $KeyFullPath).Access
    $ModifyRightsPresent = 0
    $ModifyRightsDetails = ""
    foreach ($Item in $AccessObject)
    {
        if (($Item.IdentityReference -notlike "*Network Service") -And ($Item.IdentityReference -notlike "*Local Service"))
        {
            continue
        }
        if ( $Item.AccessControlType -ne "Allow"){continue}
        $ModifyRightsTemp = 0
        CheckModifyAccess $Item ([REF]$ModifyRightsTemp)
        if($ModifyRightsTemp) {
            $ModifyRightsPresent = 1; 
            $ModifyRightsDetails += ( " "+$Item.IdentityReference+":"+$Item.RegistryRights+"; ")
        }
    }
    if ($ModifyRightsPresent) 
    {
        $Script:Modifiable += 1 
        AddToLog ($Key.name + " [" + $ModifyRightsDetails +"]")
    }  
    else 
    {
        $Script:NonModifiable += 1 
        #$Key.name + " NO MODIFY RIGHTS"
    }
}

#
# Main Program
#

MakeLogFolder

AddToLog ("###################################################")
AddToLog ("Start " + (Get-date).ToString())
AddToLog ("###################################################")
AddToLog ("System Information")
$SysInfo = SystemInfo
foreach ($SysInfoLine in $SysInfo) 
{
    AddToLog ($SysInfoLine)
}
AddToLog ("---------------------------------------------------")


$wapref = $warningpreference 
$warningpreference = "silentlycontinue"
$warningpreference = "stop"
$eapref = $ErrorActionPreference
$ErrorActionPreference = "silentlycontinue"
$warningpreference = "stop"

cd HKLM:
# Finding List of all keys

dir -recurse | format-table name | `
    out-file -filepath ((get-item env:SystemDrive) +"testlogs\RegistryKeyList.txt") -append -width 3000

$KeyNameFile = [System.IO.File]::OpenText("d:\scripts\Guy.txt")
while($Machine = $GuyFile.ReadLine())
{ get-WmiObject -computername $Machine Win32_computersystem }
$GuyFile.Close()

$warningpreference = $wapref
$ErrorActionPreference = $eapref

AddToLog ("---------------------------------------------------")
AddToLog ("Total Items processed   = " + ($Modifiable + $NonModifiable))
AddToLog ("Modifiable              = " + $Modifiable)
AddToLog ("Not Modifiable          = " + $NonModifiable)
AddToLog ("###################################################")
AddToLog ("END " + (Get-date).ToString())
AddToLog ("###################################################")


