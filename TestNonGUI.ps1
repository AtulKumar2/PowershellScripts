function TestNonGUIMain()
{
	Write-Output $MyInvocation.ScriptName
	$MyInvocation 
}

#TestNonGUIMain
$MyInvocation
#$MyInvocation.CommandOrigin.gettype()
#$MyInvocation.CommandOrigin -eq "runspace"
#$MyInvocation.CommandOrigin

sleep -Seconds 3000