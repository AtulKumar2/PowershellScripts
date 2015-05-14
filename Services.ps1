################################################################################
# Services.ps1 
#
# Atul Kumar 
# 2015-05-14 
# Valid only on local machine
################################################################################
# RestartService, StopService, DisableService, DeleteService
# Delete-Diagtrack, Disable-Diagtrack
################################################################################

# Check if PowerShell is running elevated
function Check-Elevated
{
  $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
  $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
  $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
  $IsAdmin=$prp.IsInRole($adm)
  if ($IsAdmin){
    Set-Variable -Name elevated -Value $true -Scope 1
  }
}

# Restart a service
function RestartService([string] $ServiceName)
{
    $ServiceRef = Get-Service $ServiceName
	if (($ServiceRef) -eq $null){
		return "$ServiceName does not exist."
	}
    if($ServiceRef.Status -eq [ServiceProcess.ServiceControllerStatus]::Running) { 
		return $true
	}
    if($ServiceRef.Status -ne [ServiceProcess.ServiceControllerStatus]::StartPending) { 
	    $ServiceRef = Restart-Service $ServiceName -Force
	    trap{return "Unable to restart service"}
	}

    $Running = $false
	for( $cnt = 0; $cnt -lt 10; $cnt++)
    {
		$ServiceRef = Get-Service $ServiceName
		if($ServiceRef.Status -eq [ServiceProcess.ServiceControllerStatus]::Running) { 
			$Running = $true
			break 
		}
		Start-Sleep -Seconds 30
	}
	if (!$Running){
		return "<$Servicename> restart failed."
	}
	return $true
}

# Restart a service
function StopService([string] $ServiceName)
{
    $ServiceRef = Get-Service $ServiceName
    if (($ServiceRef) -eq $null){
		return "$ServiceName does not exist."
	}
	if($ServiceRef.Status -eq [ServiceProcess.ServiceControllerStatus]::Stopped) { 
		return $true
	}
    if($ServiceRef.Status -ne [ServiceProcess.ServiceControllerStatus]::StopPending) { 		  
	    $ServiceRef = Stop-Service $ServiceName -Force
	    trap{return "Unable to stop service"}
	}
  
	$Stopped = $false
	for( $cnt = 0; $cnt -lt 10; $cnt++)
    {
		$ServiceRef = Get-Service $ServiceName
		if($ServiceRef.Status -eq [ServiceProcess.ServiceControllerStatus]::Stopped) { 
			$Stopped = $true
			break 
		}
		Start-Sleep -Seconds 15
	}
	if (!$Running){
		return "<$Servicename> stop failed."
	}
	return $true
}

# Disable a service
function DisableService([string] $ServiceName)
{
    $ServiceRef = Get-WmiObject "Win32_service" -Filter ("Name='" + $ServiceName + "'")
	if (($ServiceRef) -eq $null){
		return "$ServiceName does not exist."
	}
	if($ServiceRef.StartMode -eq [ServiceProcess.ServiceStartMode]::Disabled) { 
		return $true
	}
    if($ServiceRef.State -ne [ServiceProcess.ServiceControllerStatus]::Stopped) {
        $status = StopService $ServiceName 
		if($status -ne $true){
		    return $status
        }
	}
	$ServiceRef = Set-Service -Name $ServiceName -StartupType Disabled
	trap{return "Unable to disable service"}
	
    $Disabled = $false
    for( $cnt = 0; $cnt -lt 18; $cnt++)
    {
		$ServiceRef = = Get-WmiObject "Win32_service" -Filter ("Name='" + $ServiceName + "'")
		if($ServiceRef.Status -eq [ServiceProcess.ServiceStartMode]::Disabled) { 
			$Disabled = $true
			break 
		}
		Start-Sleep -Seconds 10
	}
	if (!$Disabled){
		return "<$Servicename> disable failed."
	}
	return $true
}

# Delete a service
function DeleteService([string] $ServiceName)
{
    $ServiceRef = Get-WmiObject "Win32_service" -Filter ("Name='" + $ServiceName + "'")
	if (($ServiceRef) -eq $null){
		return $true
	}
    if($ServiceRef.State -ne [ServiceProcess.ServiceControllerStatus]::Stopped) { 
		$status = StopService $ServiceName 
		if($status -ne $true){
		    return $status
        }
	}
	if($ServiceRef.StartMode -ne [ServiceProcess.ServiceStartMode]::Disabled) {
        $status = DisableService $ServiceName 
		if($status -ne $true){
		    return $status
        }
	}

    $ServiceRef = (Get-WmiObject "Win32_service" -Filter ("Name='" + $ServiceName + "'")).delete()
	trap{return "Unable to delete service"}
	
	return $true
}


# New Doagtrack service enables keylogging 2015-05-14
# http://thepcwhisperer.blogspot.in/2014/10/microsofts-windows-10-preview-has-built.html
# https://support.microsoft.com/en-us/kb/2976978
function Delete-DiagTrack()
{
    Check-Elevated
    If ($elevated -ne $true){
	    Write-Error "Please run PowerShell as administrator before you run this script."
	    return $false 
    }

    $ServiceName = "DiagTrack"     
    Write-Output ("Deleting Service $ServiceName")
    $status = DeleteService $ServiceName
    if ($status -ne $true){
        return $status
    }
    Write-Output ("Deleting Service $ServiceName success")
    return $true
}
function Disable-DiagTrack()
{
   Check-Elevated
   If ($elevated -ne $true){
	   Write-Error "Please run PowerShell as administrator before you run this script."
	   return $false 
   }

    $ServiceName = "DiagTrack"
    Write-Output ("Disabling Service $ServiceName")
    $status = DisableService $ServiceName
    if ($status -ne $true){
        return $status
    }
    Write-Output ("Disabling Service $ServiceName success")
    return $true
}

################################################################################
# Don't remember what this was supposed to do
# Make a service to run as own service in its own SvcHost
#param( [string]$ServiceName="MyService", [Int32]$TotalIteration=10000, $LogInterval=50, `
#		[switch]$ModifyService, [switch]$NoElevationCheck, [switch]$CorrectStopServiceError)


function ChangeServiceToRunAsOwn([string]$ServiceName)
{
	$ServiceRef = Get-WmiObject "Win32_service" -Filter ("Name='" + $ServiceName + "'")
	if (($ServiceRef) -eq $null){
		Write-Error "$ServiceName does not exist."
		return $false
	}
	$InParams = $ServiceRef.GetMethodParameters("Change")	
	$InParams["ServiceType"] = 16 # Run as own

	$R = $ServiceRef.InvokeMethod("Change", $inParams, $Null) 

	if ($R.ReturnValue -ne 0) {
		return ("Failure Result of change : " + $R.ReturnValue)
	}else {	
		return $true
	}
}

function VerifyRulesOnService([string] $ServiceName)
{
	$ServiceRef = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
	if($ServiceRef -eq $null){
		return "Need to install/enable <$ServiceName> service"
	}
	if ($ServiceRef.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running){
		return "<$ServiceName> is not in running state. Shutdown cleanly."
	}
	$ServiceAppList = tasklist /FI ("Services eq $ServiceName") /NH
	if ($ServiceAppList.GetType() -eq [System.String]){
		return "<$ServiceName> data could not be retrieved"
	}
	if ($ServiceAppList.Length -gt 2){
		Write-Output $ServiceAppList
		return "<$ServiceName> is running in multiple processes"
	}
	return $true
}

function TestService()
{
	param( [string]$ServiceName = "WinService",`
		[int]$TotalIteration = 10000, [int]$LogInterval = 50)
		
	$ServiceRef = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
	if($ServiceRef -eq $null){
		return "$ServiceName does not exist"
	}
	if ($ServiceRef.Status -ne [ServiceProcess.ServiceControllerStatus]::Running){
		return "$ServiceName is not in running state"
	}
	$ServiceAppList = tasklist /FI ("Services eq " + $ServiceName) /NH
	if ($ServiceAppList.GetType() -eq [System.String]){
		return "<$ServiceName> data could not be retrieved."
	}
	
	$ServicePID = 0
	if($false -eq [Int32]::TryParse( $ServiceAppList[1].ToString().Split( `
		" ", [StringSplitOptions]::RemoveEmptyEntries)[1], [Ref]$ServicePID)){
		Write-output $ServiceAppList[1]
		return "<$ServiceName> Unable to retrieve PID."
	}
	Write-Output ((Get-Date -format "yyyyMMdd_hhmm") + ": Iteration 0" )
	Write-Output (tasklist /FI ("Services eq " + $ServiceName))
	
	for ($Cnt=0; $Cnt -lt $TotalIteration; $Cnt++)
	{
		switch ($ServiceName.ToLower())
		{
		"winservice1" {$ObjList = gwmi -Class "Win32_Share" -ErrorAction SilentlyContinue }
		"winservice2" {$ObjList = Get-WSManInstance -Enumerate wmicimv2/* `
							-filter "select * from win32_service where State = 'Running'"}
		}
		if ((($Cnt+1) % $LogInterval) -eq 0)
		{
			$MemHeader = ((Get-Date -format "yyyyMMdd_hhmm") + ": Iteration " + ($Cnt+1))
			$MemValue = (tasklist /FI ("Services eq " + $ServiceName) /NH)[1].ToString().Split( `
				" ", [StringSplitOptions]::RemoveEmptyEntries)
			Write-Output ($MemHeader + "`t" + $MemValue[4] + " " + $MemValue[5])	
		}
	}
}

# Unable to remember what this was for so putting in its own function	

################################################################################
# Main Logic of this script
# Run in Administrative powershell command line
# Running by right clicking on it will not work due to transcripting feature
#
# Always run like 
# Try {.\Services.ps1} Finally {Stop-Transcript}
# Try {.\Services.ps1 <arguments>} Finally {Stop-Transcript}
# Finally is needed to make sure transcript is stopped and log is released
################################################################################
function RunTest()
{
    if(!$NoElevationCheck)
    {
	    Check-Elevated
	    If ($elevated -ne $true){
		    Write-Error "Please run PowerShell as administrator before you run this script."
		    return $false 
	    }
    }

    $TranscriptSupport = $false
    if ($MyInvocation.CommandOrigin -eq "Runspace")
    {
	    $TranscriptSupport = $true
	    $Self = (Resolve-Path $MyInvocation.InvocationName).ToString()
	    if (![IO.File]::Exists($Self)) {$TranscriptSupport = $false}
    }
    if (($MyInvocation.CommandOrigin -eq "Internal") -and `
	    ($MyInvocation.InvocationName) )
    {
	    $TranscriptSupport = $true
	    $Self = (Resolve-Path $MyInvocation.InvocationName).ToString()
	    if (![IO.File]::Exists($Self)) {$TranscriptSupport = $false}
    }
    if (!$TranscriptSupport)
    {
	    Write-warning ("Unable to start transcript." + `
		    "Consider running this from Powerhsell command line as stand alone script." +`
		    "Some host may not support transcript like PowerGUI.")
    }

    # Reasonable attempt to create random file name			
    if ($TranscriptSupport)
    {
	    $dt = Get-Date -format "yyyyMMdd_hhmm"
	    $log = $Self.Replace(".ps1",("-"+$dt+"-"+((Get-Random)%10000).ToString()+".log"))
	    while ([IO.File]::Exists($log)){
		    Sleep -Seconds 30
		    $log = $Self.Replace(".ps1",("-"+$dt+"-"+((Get-Random)%10000).ToString()+".log"))
	    }
	    trap { Write-Warning "Unable to create Log file name. No transcript will be created."; break }
	    start-transcript $log
	    trap { stop-transcript; break}
    }

    if (($ret = VerifyRulesOnService $ServiceName) -ne $true)
    {
	    if ($CorrectStopServiceError)
	    {
		    if((RestartService $ServiceName) -ne $true){
			    if($TranscriptSupport) {stop-transcript}
			    return $false
		    }
	    }
	    Write-Output $ret
	    if($TranscriptSupport) {stop-transcript}
	    return $false
    }

    # Make sure service is running in its own process
    if ($ModifyService)
    {
	    if (($ret = ChangeServiceToRunAsOwn $ServiceName) -ne $true){
		    Write-Output $ret
		    if($TranscriptSupport) {stop-transcript}
		    return $false
	    }
	    if (($ret = RestartService $ServiceName) -ne $true){
		    Write-Output $ret
		    if($TranscriptSupport) {stop-transcript}
		    return $false
	    }
    }

    Write-Output ("Service under test is " + $ServiceName)
    Write-Output ("Total Iterations = " + $TotalIteration)
    Write-Output ("Logging done at interval = " + $LogInterval)

    TestService $ServiceName -LogInterval $LogInterval -TotalIteration $TotalIteration
    
    if($TranscriptSupport) {stop-transcript}
    trap { if($TranscriptSupport) {stop-transcript}; break}
}

