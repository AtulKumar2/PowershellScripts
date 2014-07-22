#==============================================================================
# 3 ways to enable and disable a physical network interface using WMI.
# All boils down to finding device id of a relevant interface
# All gets into a single function as you see, so this function can be 
# used in pipeline out of this script also.
# Tested using Powershell 2.0 on windows 7 x64 ultimate.
#==============================================================================

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

function EnableDisableIF()
{
	begin {
		"Enabling and disabling few nw interfaces"
		$Script:Total = 0
	}
	process{
		$Script:Executed=$true
		if ($_.GetType() -eq [Int] ) { $DevID = $_ } else {$DevID = $_.DeviceID}
		(gwmi win32_networkadapter -filter ("deviceid=" + $DevID)).disable()
		trap {$Script:Executed = $false; continue}
		if ($Script:Executed) {
			(gwmi win32_networkadapter -filter ("deviceid=" + $DevID)).enable()
			trap {$Script:Executed = $false; continue}
		}
		if ($Script:Executed) {$Script:Total += 1}
	}
	end{ ("Tried to Modify " + $Script:Total + " Interfaces") }
}
	
Check-Elevated
if (!$elevated) {Write-Warning "Not much advantage running as non-admin"; return}

#This should work in most cases even when network interface has been disabled for some reason 
$(gwmi win32_networkadapter) | ?{$_.MACAddress -ne $null} | EnableDisableIF

#I will prefer using above one, but this one can alse be used
#gwmi win32_networkadapter -Filter "NetEnabled=true"  | EnableDisableIF

# Use below if you know interface id. Uncomment & change interface id to use it
# 7 | EnableDisableIF


