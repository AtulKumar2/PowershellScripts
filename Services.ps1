param( [string]$ServiceName="MyService", [Int32]$TotalIteration=10000, $LogInterval=50, `
		[switch]$ModifyService, [switch]$NoElevationCheck, [switch]$CorrectStopServiceError)

# Function to check if PowerShell is running elevated
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

#Make a service to run as own service in its own SvcHost
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

# Restart a service
function RestartService([string] $ServiceName)
{
	$ServiceRef = Restart-Service $ServiceName -Force
	trap{return "Unable to restart service"}
	$Running = $false
	for( $cnt = 0; $cnt -lt 10; $cnt++){
		$ServiceRef = Get-Service $ServiceName
		if($ServiceRef.Status -eq [ServiceProcess.ServiceControllerStatus]::Running) { 
			$Running = $true
			break 
		}

		Sleep -Seconds 30
	}
	if (!$Running){
		return "<$Servicename> restart failed."
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
	
	for ($Cnt=0; $Cnt -lt $TotalIteration; $Cnt++){
		switch ($ServiceName.ToLower()){
		"winservice1" {$ObjList = gwmi -Class "Win32_Share" -ErrorAction SilentlyContinue }
		"winservice2" {$ObjList = Get-WSManInstance -Enumerate wmicimv2/* `
					-filter "select * from win32_service where State = 'Running'"}
		}
		if ((($Cnt+1) % $LogInterval) -eq 0){
			$MemHeader = ((Get-Date -format "yyyyMMdd_hhmm") + ": Iteration " + ($Cnt+1))
			$MemValue = (tasklist /FI ("Services eq " + $ServiceName) /NH)[1].ToString().Split( `
				" ", [StringSplitOptions]::RemoveEmptyEntries)
			Write-Output ($MemHeader + "`t" + $MemValue[4] + " " + $MemValue[5])	
		}
	}
}

###############################################################################
# Main Logic of this script
# Better run in Administrative powershell command line
# Running by right clicking on it will not work due to transcripting feature
#
# Always run like 
# Try {.\Services.ps1} Finally {Stop-Transcript}
# Try {.\Services.ps1 <arguments>} Finally {Stop-Transcript}
# Finally is needed to make sure transcript is stopped and log is released
###############################################################################
if(!$NoElevationCheck){
	Check-Elevated
	If ($elevated -ne $true){
		Write-Error "Please run PowerShell as administrator before you run this script."
		return $false 
	}
}

$TranscriptSupport = $false
if ($MyInvocation.CommandOrigin -eq "Runspace"){
	$TranscriptSupport = $true
	$Self = (Resolve-Path $MyInvocation.InvocationName).ToString()
	if (![IO.File]::Exists($Self)) {$TranscriptSupport = $false}
}
if (($MyInvocation.CommandOrigin -eq "Internal") -and `
	($MyInvocation.InvocationName) ){
	$TranscriptSupport = $true
	$Self = (Resolve-Path $MyInvocation.InvocationName).ToString()
	if (![IO.File]::Exists($Self)) {$TranscriptSupport = $false}
}
if (!$TranscriptSupport){
	Write-warning ("Unable to start transcript." + `
		"Consider running this from Powerhsell command line as stand alone script." +`
		"Some host may not support transcript like PowerGUI.")
}

#Reasonable attempt to create random file name			
if ($TranscriptSupport){
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
	
if (($ret = VerifyRulesOnService $ServiceName) -ne $true){
	if ($CorrectStopServiceError){
		if((RestartService $ServiceName) -ne $true){
			if($TranscriptSupport) {stop-transcript}
			return $false
		}
	}
	Write-Output $ret
	if($TranscriptSupport) {stop-transcript}
	return $false
}
#Make sure service is running in its own process
if ($ModifyService){
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