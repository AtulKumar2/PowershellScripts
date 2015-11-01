<##>
$STR_Deleting         = "Deleting"
$STR_DeletingContent  = "Deleting Content"
$STR_Err_PathNotExist = "Path Not exist"
$STR_Started          = "Started"
$STR_Finished         = "Finished"

Function Close-Applications
{
    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [string]$UserRoot
    )
    Write-Output -InputObject:"Application closure: $STR_Started"

    $AppList = @{}
    $AppList["Skype"] = "Skype"
    $AppList["Skype Apps"] = "Skype*"
    $AppList["Google Apps"] = "Google*"
    $AppList["Google Chrome"] = "Chrome"
    $AppList["Mozilla Firefox"] = "Firefox"
    $AppList["Java Update Scheduler"] = "jusched"
    $AppList["Internet Explorer"] = "iexplore"


    foreach ($App in $AppList.GetEnumerator()){
        $AppName = $App.Name
        $Apps = Get-Process -Name:$App.Value -ErrorAction:SilentlyContinue
        if ($Apps -eq $Null){
            Write-output -InputObject:"$AppName : Not Found"
            continue
        }
        Write-output -InputObject:"$AppName : Stopping"
        foreach ($AppEntry in $Apps){
            $AppEntryName = $AppEntry.ProcessName
            Write-output -InputObject:"$AppEntryName : Stopping"
            Stop-Process -Name:$AppEntryName -Force -ErrorAction:SilentlyContinue
            for ($cnt = 0; $cnt -lt 6; $cnt++){
                if ((Get-Process -Name:$AppEntryName -ErrorAction:SilentlyContinue)){
                    sleep -Seconds 10
                }
            }
            if ((Get-Process -Name:$AppEntryName -ErrorAction:SilentlyContinue)){
                Write-Warning -Message:"$AppEntryName : Failed Stopping"
            }
        }
    }
    Write-Output -InputObject:"Application closure: $STR_Finished"
}

Function Delete-Windows-Content
{
    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [string]$UserRoot
    )
    Write-Output -InputObject:"Application Data Empty: $STR_Started"

    $Local = Join-path -Path:$UserRoot -ChildPath:"AppData\Local"
    $LocalLow = Join-path -Path:$UserRoot -ChildPath:"AppData\LocalLow"
    $Roaming = Join-path -Path:$UserRoot -ChildPath:"AppData\Roaming"

    $Folders = @()

    $LocalFolders = @("Diagnostics", "Temp")
    $LocalFolders += @("Microsoft\Windows\Temporary Internet Files", "Microsoft\Windows\WER", `
            "Microsoft\Windows\WebCache")
    $LocalFolders += @("Adobe\Acrobat\DC","Adobe\AcroCef\DC\Acrobat","Adobe\Color")
    $LocalFolders += @("Google\CrashReports", "Google\Chrome\User Data", "Google\Drive\user_default")
    $LocalFolders += @("Google\Google Talk Plugin\data", "Google\Hangouts Plugin for Microsoft Outlook\Tracing\OUTLOOK")
    $LocalFolders += @("Google\Chrome Cleanup Tool")
    Foreach ($LocalFolder in $LocalFolders){
        $Folders += Join-Path -Path:$Local -ChildPath:$LocalFolder
    }

    $LocalLowFolders = @("Adobe\Acrobat\DC", "Lastpass", "Temp")
    $LocalLowFolders += @("Sun\Java\Deployment\Log", "Sun\Java\Deployment\Cache")
    Foreach ($LocalLowFolder in $LocalLowFolders){
        $Folders += Join-Path -Path:$LocalLow -ChildPath:$LocalLowFolder
    }

    $RoamingFolders = @("Adobe")
    $RoamingFolders += @("Mozilla\Firefox\Crash Reports")
    #$RoamingFolders += @("Mozilla\Firefox\Profiles")
    Foreach ($RoamingFolder in $RoamingFolders){
        $Folders += Join-Path -Path:$Roaming -ChildPath:$RoamingFolder
    }
    
    foreach ($Folder in $Folders){
        if (!(Test-Path -Path:$Folder -ErrorAction:SilentlyContinue)){
            continue
        }
        Write-Output -InputObject:"$Folder : $STR_DeletingContent"
        Remove-Item -Path:"$Folder\*" -Recurse -Force    
    } 
    Write-Output -InputObject:"Application Data Empty: $STR_Finished"
}

Function Cleanup-Firefox-Folders
{
    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [string]$UserRoot
    )
    Write-Output -InputObject:"Firefox Data Empty: $STR_Started"

    $Root = Join-path -path:$UserRoot -childpath:"AppData\Local\Mozilla\Firefox\Profiles"
    if (!(Test-path -Path:$Root)){
        Write-Output -InputObject:"$Root : $STR_Err_PathNotExist"
        return @(0)
    }
    if ((Get-Process -Name:"firefox" -ErrorAction:SilentlyContinue)){
        Write-Warning -Message:"Close Firefox before running this"
        return @(1)
    }
    $Profiles = @()
    foreach ($Item in (Get-ChildItem -Path:$Root -Directory -ErrorAction:SilentlyContinue)){
        $Profiles += $Item.BaseName
    }
    $SubFolders = @()
    $SubFolders += @("OfflineCache", "Safebrowsing", "StartupCache", "thumbnails")

    foreach($Profile in $Profiles){
        $ProfileRoot = Join-Path -Path:$Root -ChildPath:$Profile
        if ((Test-Path -Path:"Cache" -ErrorAction:SilentlyContinue)){
            $SubFolders += "Cache"
        } 
        $cnt = 1
        while ($true){
            if ((Test-Path -Path:"Cache$cnt" -ErrorAction:SilentlyContinue)){
                $SubFolders += "Cache$cnt"
            }else{
                break
            }
        }
        foreach ($SubFolder in $SubFolders){
            $SubFolderRoot = Join-Path -Path:$ProfileRoot -ChildPath:$SubFolder
            if(!(Test-Path -Path:"$SubFolderRoot" -ErrorAction:SilentlyContinue)){
                Write-Warning -Message:"$SubFolderRoot : $STR_Err_PathNotExist"
                continue
            }
            Write-Output -InputObject:"$SubFolderRoot : $STR_DeletingContent"
            Remove-Item -Path:"$SubFolderRoot\*" -Recurse -Force -ErrorAction:Continue
        }
    }

    Write-Output -InputObject:"Firefox Data Empty: $STR_Finished"
}
