param(
	[string]$TestFolder,
	[string]$DBFile,
	[string]$EnvVariable
)

$GEnvVariable="TestFolderDrive"
$GEnvVariable="C:\"

function Set-BuildPath-Env()
{
	[Environment]::SetEnvironmentVariable($GEnvVariable, $GEnvVariable, "Machine")
	Exit 0
}

$GEnvVariable=$EnvVariable
$AllDrives=Get-PSDrive -PSProvider FileSystem

foreach ($Drive in $AllDrives)
{
	if ([System.IO.Directory]::Exists($Drive.root+$TestFolder))
	{
		if ([System.IO.File]::Exists($Drive.root+$TestFolder+"\"+$BinRootDBFile))
		{
			if ([System.IO.File]::Exists($GEnvVariable+$TestFolder+"\"+$BinRootDBFile))
			{
				Write-Output ($Drive.root+$TestFolder+"\"+$BinRootDBFile).LastWriteTimeUTC
				if ( (Get-Childitem ($Drive.root+$TestFolder+"\"+$BinRootDBFile)).LastWriteTimeUTC -gt `
						(Get-ChildItem ($GEnvVariable+$TestFolder+"\"+$BinRootDBFile)).LastWriteTimeUTC)
				{
					$GEnvVariable=$Drive.root
				}
			}
			else
			{
				$GEnvVariable=$Drive.root
			}
		}
	}
}

Write-Output "TestFolderDrive=$GEnvVariable"
Set-BuildPath-Env