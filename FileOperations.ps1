# Creation date : 20131030
# Creator : Atul Kumar
# File related operations

# Convert file names to proper case names
# Converts first alphabet to uppercase
function convert-filenames-to-propercase
{
    param{
        [parameter(mandatory=$true)][string]$Folder,
        [string]$FileFilter=$null,
        [bool]$recurse=$false
    }

    $m_FileFilter="*.*";
    if ($FileFilter -ne $null) { $m_FileFilter=$FileFilter };

    foreach ($item in (Get-Item -Path "$Folder\\*" -Filter $m_FileFilter -recurse $recurse | ?{$_.Attributes -notlike "Directory"})) 
	{
		$newname = $item.basename.Trim();
		Rename-Item -Path ($item.fullname) -NewName $newname -WhatIf:$false
	}
}

