# Parses http://up-for-grabs.net/#/ to output a comma separated list of items
# that can then copied to exvel for better searching

function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

# https://rkeithhill.wordpress.com/2008/05/11/effective-powershell-item-13-comparing-arrays-in-windows-powershell/
function AreArraysEqual($a1,$a2)
{
    #if ($a1 -isnot [array] -or $a2 -isnot [array]) {
    #  throw "Both inputs must be an array"
    #}
    if ($a1.Rank -ne $a2.Rank) {
      return $false 
    }
    if ([System.Object]::ReferenceEquals($a1, $a2)) {
      return $true
    }
    for ($r = 0; $r -lt $a1.Rank; $r++) {
      if ($a1.GetLength($r) -ne $a2.GetLength($r)) {
            return $false
      }
    }

    $enum1 = $a1.GetEnumerator()
    $enum2 = $a2.GetEnumerator()   

    while ($enum1.MoveNext() -and $enum2.MoveNext()) {
      if ($enum1.Current -ne $enum2.Current) {
            return $false
      }
    }
    return $true
} 

# Download content from web directly
$URL = "http://up-for-grabs.net/#/"
$HTML = Invoke-WebRequest -Uri $URL
$script_blocks = $HTML.ParsedHtml.getElementsByTagName("script") | ` 
					Where{ $_.type -eq ‘text/javascript’ }

# START LOCAL_FILE_SECTION
# If using a local file, uncomment all lines till # END LOCAL_FILE_SECTION 
# and comment out above lines
# $HTML = New-Object -ComObject "HTMLFile";
# $source = Get-Content -Path (Join-Path (Get-ScriptDirectory) "Up-For-Grabs.net.htm") -Raw;
# $HTML.IHTMLDocument2_write($source);
# $script_blocks = $HTML.getElementsByTagName("script") |  
					Where{ $_.type -eq ‘text/javascript’ }
# END LOCAL_FILE_SECTION

$file_block = ""
foreach ($script_block in $script_blocks)
{
    if($script_block.innerHTML -ne $null -and `
        $script_block.innerHTML.trim().StartsWith("var files"))
    {
        $file_block = $script_block.innerHTML.trim()
    }
}

$file_string = $file_block.Substring( `
		$file_block.IndexOf("=") + 1, ` 
		$file_block.IndexOf(";") - $file_block.IndexOf("=") - 1).trim();

$file_json = $file_string | ConvertFrom-Json

$delim = " ; "

Write-Output ("name" + $delim + "desc" + $delim + "site" + $delim + "upforgrabslink" + $delim + "tags")

foreach ($item in $file_json | gm)
{
	$props = $file_json.$($item.Name)
	if($props.MemberType) {continue}

	$row = $props.name.ToString()
	$row += $delim + $props.desc.ToString()
	$row += $delim + $props.site.ToString()

	$row += $delim
	foreach ($subitem in $props.upforgrabs | gm){
		if($subitem.Name -ne "link") {continue}
		$row += $subitem.ToString().split("=")[1]
	}
	
	$sorted_tags = $props.tags | Sort-Object
	#if ($false -eq (AreArraysEqual $sorted_tags $props.tags)){
	#	echo "Did not match"
	#}
	foreach ($tag in $sorted_tags){
		$row += $delim + $tag.ToString()
	}
	
	Write-Output $row
}

# Working with Powershell custom objects
# https://technet.microsoft.com/en-us/library/ff730946.aspx

# Read local file as HTML document
# http://stackoverflow.com/questions/24977233/parse-local-html-file/24989452#24989452

# An Introduction to JavaScript Object Notation (JSON) in JavaScript and .NET
# https://msdn.microsoft.com/en-us/library/bb299886.aspx

# Get-Scriprt Directory
# http://blogs.msdn.com/b/powershell/archive/2007/06/19/get-scriptdirectory.aspx
# http://stackoverflow.com/questions/801967/how-can-i-find-the-source-path-of-an-executing-script/6985381#6985381

# Powershell array sorting
# http://blogs.technet.com/b/heyscriptingguy/archive/2011/12/06/add-modify-verify-and-sort-your-powershell-array.aspx

# Output custom objects as CSV
# http://learn-powershell.net/2014/01/24/avoiding-system-object-or-similar-output-when-using-export-csv/