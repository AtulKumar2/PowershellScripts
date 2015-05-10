
Function StartLogging ([string]$FileLocation)
{
	$dt = Get-Date -format "yyyyMMdd_hhmm"
	$log = ($MyInvocation.MyCommand.Name).Replace(".ps1","_$dt.log")
	$file = "..\..\" + $log
	start-transcript $file
	trap { stop-transcript; break}
	.\_DeployHostApplication.ps1 -Env QA -WebTargetName \\Server01\Services
	stop-transcript
}