# Parses http://up-for-grabs.net/#/ to output a comma separated list of items
# that can then copied to exvel for better searching

# Download content from web directly
$URL = "http://up-for-grabs.net/#/"
$HTML = Invoke-WebRequest -Uri $URL
$script_blocks = $HTML.ParsedHtml.getElementsByTagName("script") | ` 
					Where{ $_.type -eq ‘text/javascript’ }

# START LOCAL_FILE_SECTION
# If using a local file, uncomment all lines till # END LOCAL_FILE_SECTION 
# and comment out above lines
#$HTML = New-Object -ComObject "HTMLFile";
#$source = Get-Content -Path ".\Up-For-Grabs.net.htm" -Raw;
#$HTML.IHTMLDocument2_write($source);
#$script_blocks = $HTML.getElementsByTagName("script") | ` 
#					Where{ $_.type -eq ‘text/javascript’ }
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

Write-Output ("name,desc,site,upforgrabslink,tags")

$delim = " ; "
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
	
	foreach ($tag in $props.tags){
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