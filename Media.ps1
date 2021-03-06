################################################################################
# MULTIMEDIA
################################################################################

#function GetMediaObjects1()
#{
#	param(
#		[String]$FolderName,
#		[String]$FileName
#	)
#	#http://huddledmasses.org/editing-media-tags-from-powershell/
#	#http://developer.novell.com/wiki/index.php/TagLib_Sharp
#	$temp = [AppDomain]::CurrentDomain.GetAssemblies() | ?{$_.fullname -like "taglib-sharp*"}
#	if ( $temp -eq $null){
#		Write-Host "taglib-sharp is not loaded. use below command to load it";
#		Write-Host "[Reflection.Assembly]::LoadFrom( (Resolve-Path <Path of \taglib-sharp.dll>) )";
#		return (@())
#	}
#	
#	$mediaExtensionList = @(".asf",".avi",".flac",".m4a",".m4p",".m4v", `
#       		".mp+",".mp3",".mp4",".mpc",".mpe",".mpeg",".mpg", `
#       		".mpp",".mpv2",".ogg",".wav",".wma",".wmv",".wv")
#	
#	$CorrectParam = $false
#	$FileList = @()
#	if ($FolderName) { 
#		if (![System.IO.Directory]::Exists($FolderName)){
#			Write-Host ($FolderName + " : Target folder does not exist.");
#			return (@())
#		}else{
#			$FileList = dir -Recurse -Include "*.*" -Path $FolderName |  `
#				?{($_ -is [IO.FileSystemInfo]) -and ($mediaExtensionList -contains $_.Extension)}
#			$CorrectParam = $true
#		}
#	}
#	if ($FileName){ 
#		if(![System.IO.File]::Exists($FileName)){
#			Write-Host ($FileName + " : Target file does not exist.");
#			return (@())
#		}else {
#			$FileList += dir $FileName |  `
#				?{($_ -is [IO.FileSystemInfo]) -and ($mediaExtensionList -contains $_.Extension)}
#			$CorrectParam = $true
#		}
#	}
#	if (!$CorrectParam){ return "Provide some correct folder or file name"}
#			
#	$MediaObjList=@()
#	
#	ForEach ($Item in $FileList){
#		#http://huddledmasses.org/trap-exception-in-powershell/
#		#Excellent article
#		trap [Exception]{
#			Write-Host ($Item.FullName + " threw exception.");
#			Write-Host ("`tTRAPPED: " + $_.Exception.GetType().FullName); 
#  			Write-Host ("`tTRAPPED: " + $_.Exception.Message); 
#			continue
#		}
#		$MediaObjList += [TagLib.File]::Create($Item.FullName)
#	}
#	return ($MediaObjList)
#}


# USAGE:
# ModifyMediaFiles "G:\Music\Movies\K" -debug
# ModifyMediaFiles "G:\Music\Movies\K"

#function ModifyMediaFiles1()
#{
#	param(
#		[parameter(mandatory=$true)]
#		[string]$FolderName, 
#		[String]$TagName="Genres", 
#		[parameter(mandatory=$true)]
#		[String]$NewTagValue
#	)
#	
#	Write-Host $("Only display the name of those which are getting modified");
#	foreach ($media in @(GetMediaObjects($FolderName))){
#		if (($media.tag.$TagName -contains $NewTagValue) `
#		 -and ($media.tag.$TagName.length -eq 1 ) ){
#			continue;
#		}
#		$media.tag.$TagName=@($NewTagValue)
#		$media.save()
#		$media.name
#	}
#}

# USAGE:
# ShowMedia-WrongTitle
# ShowMedia-WrongTitle "G:\Music\Movies\" -debug
# ShowMedia-WrongTitle "G:\Music\Movies\Aagey Se Right" 

#function ShowMedia-WrongTitle([string]$FolderName=".")
#{
#	$TagName="Title"
#	$ObjList=@()
#	$DirtyObject=$false
#	foreach ($media in @(GetMediaObjects($FolderName))){
#		if ($media.Name -inotmatch $media.tag.$TagName){
#			$ObjList += $media
#			$DirtyObject=$true
#		}
#	}
#	if ($DirtyObject){
#		Write-Host "Mismatched title and names were found"
#		foreach ($media in $ObjList){
#			Write-Host $(([String]::Join(";=;",$media.tag.$TagName)+" : "+$media.Name));
#		}
#	}else{ Write-Host "No Mismatched title and names were found" }
#}



# USAGE:
# ShowMediaTags
# ShowMediaTags "G:\Music\Movies\" -debug
# ShowMediaTags "G:\Music\Movies\Aagey Se Right" 

#function ShowMediaTags1([string]$FolderName=".", [string]$TagName="Genres")
#{
#	foreach ($media in @(GetMediaObjects($FolderName))){
#		Write-Host $(([String]::Join(";=;",$media.tag.$TagName)+" : "+$media.Name));
#	}
#}


#dir -Recurse -Include "*(megablast.us)*.*"
#(dir -Recurse -Include '*`[*') | Where-Object { $_.Attributes -like "Directory" } | ft fullname
#(dir -Recurse -Include '*`]*') | Where-Object { $_.Attributes -like "Directory" } | ft fullname
#dir -Recurse -Include '*`[*.*' | ft @{ Label="newname"; Expression={$_.fullname -replace '\[', 'a'} }
#dir -Recurse -Include '*`[*.*' | ForEach-Object{ [System.IO.File]::Move($_.fullname, $_.fullname.replace("[", "(")) }
#dir -Recurse -Include '*`]*.*' | ForEach-Object{ [System.IO.File]::Move($_.fullname, $_.fullname.replace("]", ")")) }
#get-childItem *.txt | rename-item -newname { $_.name -replace '\.txt','.log' }
#dir -Recurse -Include "*\(megablast.us\)*.*" | ft name, @{ Label="newname"; Expression={$_.name -replace '\(megablast.us\)', 'mb'} }
#dir -Recurse -Include "*(megablast.us)*.*" | Rename-Item  -newname {$_.name -replace '\(megablast.us\)', ''}
#dir -Recurse -Include '*.*' | ?{$_.Attributes -notlike "Directory"} | ?{$_.name -imatch $_.directory.name} | ft fullname 
#dir -Recurse -Include '*.*' | ?{$_.name -imatch $_.directory.name} | Rename-Item -NewName {($_.name -replace ("_" + $_.directory.name),"").trim() }
#dir -Recurse -Include '*.*' | Rename-Item -NewName {($_.name -replace ("- "),"").trim() } 
#dir -Recurse -Include "*.*.*" | ?{$_.attributes -like "Directory"} | ft fullname
#dir -Recurse -Include "*.*.*" | ?{$_.attributes -notlike "Directory"} | ft fullname

#dir -Recurse -Include "*-*" | ?{$_.attributes -like "Directory"} | ft fullname
#dir -Recurse -Include "*-*" | ?{$_.attributes -like "Directory"} | Rename-Item -NewName {($_.name -replace ("-"),"_").trim() }
#dir -Recurse -Include "*[1-9]*" | ?{$_.attributes -like "Directory"} | ft fullname

#https://connect.microsoft.com/feedback/ViewFeedback.aspx?FeedbackID=277707&SiteID=99#
#PS I:\> dir -Recurse -Exclude *.srt,*.txt,*.ico,*.sub,*.inf,*.nfo,*.idx | Where-Object { $_.Attributes -notlike "Directory" } | ft fullname
#dir -Recurse -Include '*megablast*.*'
#dir -Recurse -Include 'megablast*.*'
#dir -Recurse -Include '*megablast.*'
#dir -Recurse -Include '*`[megablast*`]*.*' | Where-Object { $_.Attributes -notlike "Directory" } | ft name, @{ Label="newname"; Expression={$_.name -replace '\[megablast.us\]', 'mb'} }
#dir -Recurse -Include '*`[megablast.us`]*.*' | Where-Object { $_.Attributes -notlike "Directory" } |  ForEach-Object {[System.IO.File]::Move($_.fullname, $_.fullname.replace("[megablast.us]",""))}
#dir -Recurse -Include '*`[www.megablast.us`]*.*' | Where-Object { $_.Attributes -notlike "Directory" } | ft name, @{ Label="newname"; Expression={$_.name -replace '\[www.megablast.us\]', 'mb'} }
#dir -Recurse -Include '*`[www.megablast.us`]*.*' | Where-Object { $_.Attributes -notlike "Directory" } |  ForEach-Object {[System.IO.File]::Move($_.fullname, $_.fullname.replace("[www.megablast.us] - ",""))}
#
#dir -Recurse -Include "*\(megablast.us\)*.*" | ft name, @{ Label="newname"; Expression={$_.name -replace '\(megablast.us\)', 'mb'} }
#
#dir -Recurse -include '*.*' | ?{$_.name -imatch $_.directory.name} | ?{($_.name -replace $_.directory.name, '').trim() -ne ''} | Rename-Item -newname {($_.name -replace $_.directory.name, '').trim()}
#dir -Recurse -include '*.*' | ?{$_.name -imatch $_.directory.name} | ?{($_.name -replace $_.directory.name, '').trim() -ne ''} | ForEach-Object {[System.IO.File]::Move($_.fullname, $_.fullname.replace($_.directory.name,'')).trim()}

#Modify file names to remove extraneous characters
function ModifyFileNames-RemoveExtraneousChars
{
    param(
		[string]$Folder=".",
		[string]$Recurse=$false
	)
    
    $List = @()
    if ($Recurse) { $List = Get-ChildItem -Path $Folder -Recurse | ?{$_.attributes -notlike "Directory"}}
    else  { $List = Get-ChildItem -Path $Folder | ?{$_.attributes -notlike "Directory"}}

    # Name contains strings like 01s!
    $ModifyList = $List | ?{$_.BaseName -match "\d+!s"}
    if ($ModifyList.Length -eq 0) {"No file has names containing string like 01s!"}
    else
    { 
        "Modifying " + $ModifyList.Length.tostring() + " files"
        $ModifyList | ft FullName
        $ModifyList | Rename-Item -newname {($_.name -replace "\d+!s", "").Trim()} -WhatIf:$false
    }
}


#Modify file names for various simple reasons.
# Trim, remove leading numerals, replace multiple spaces etc
function ModifyFileNames
{
	param(
		[string]$Folder=".",
		[string]$Operation=""
	)
    
    $List = @()
    if ($Operation -match "^NR")
    {
        $List = Get-ChildItem -Path $Folder | ?{$_.attributes -notlike "Directory"}
    }
    else
    {
        $List = Get-ChildItem -Path $Folder -Recurse | ?{$_.attributes -notlike "Directory"}
    }

    # Remove Numerals from beginning - [Consider trimming the name first]
    if ($Operation -match "RemoveLeadingNumerals")
    {
        $ModifyList = $List | ?{$_.BaseName.Trim() -match "^\d+"}
        if ($ModifyList.Length -eq 0) {"No file name has numeral in beginning"}
        else
        { 
            "Modifying " + $ModifyList.Length.tostring() + " files"
            $ModifyList | ft FullName
            $ModifyList | Rename-Item -newname {($_.BaseName.Trim() -replace "^\d+\s?", "") + $_.Extension} -WhatIf:$false
        }
    }
    
    # Trims file name
    if ($Operation -match "TrimName")
    {
        $ModifyList = $List | ?{$_.BaseName -notlike $_.BaseName.trim()}
        if ($ModifyList.Length -eq 0) {"No file name needs to be trimmed"}
        else
        { 
            "Modifying " + $ModifyList.Length.tostring() + " files"
            $ModifyList | ft FullName
            $ModifyList | Rename-Item -newname {$_.BaseName.Trim() + $_.Extension} -WhatIf:$false
        }
    }

    # Replaces the first character in name to upper one. Trims extra spaces also.
    if ($Operation -match "ReplaceFirstCharToUpper")
    {
        $ModifyList = $List | ?{$_.BaseName.Trim() -cmatch "^[a-z]"}

        if ($ModifyList.Length -eq 0) {"No file name has lower case as starting character"}
        else
        {
            "Modifying " + $ModifyList.Length.tostring() + " files"
            $ModifyList | ft FullName 
            
            foreach ($Item in $ModifyList)
            {
                $FirstChar = $Item.BaseName.Trim().SubString(0,1).ToUpper();
			    $ParentDir = $Item | split-path;
			    
                Rename-Item -Path ($Item.FullName) `
				    -NewName ("0" + $FirstChar + $Item.BaseName.Trim().SubString(1) + $Item.Extension)
					
			    Rename-Item -Path ($ParentDir + "\\0" + $Item.BaseName.Trim() + $Item.Extension) `
				    -NewName ($FirstChar + $Item.BaseName.Trim().SubString(1) + $Item.Extension)
            }
        }
    }

    # Modifies file name to replaces multiple spaces with single space
    if ($Operation -like "ReplaceMultipleSpaces")
    {
    }

    # Modifies file name extensions to lower case
    if ($Operation -like "Change Extension to Lower case")
    {
    }
}
#ModifyFileNames -Folder "K:\Music - Old" -Operation "NRReplaceFirstCharToUpper"
#ModifyFileNames -Folder "K:\Music - Old" -Operation "RemoveLeadingNumerals"
#ModifyFileNames -Folder "K:\Music - Old" -Operation "TrimName"
#ModifyFileNames -Folder "K:\Music - Old" -Operation "RemoveExtraneousChar"
#ModifyFileNames -Folder "K:\Music - Old" -Operation "NRRemoveExtraneousChar"
#ModifyFileNames -Folder "K:\Music - Old" -Operation "ReplaceMultipleSpaces"
#ModifyFileNames -Folder "K:\Music - Old\Yeh raat phir na aaygi" -Operation "NRReplaceMultipleSpaces"

#########################################
# Folder operations
#########################################

Function Remove-SubString-From-FolderName
{
	param(
		[parameter(mandatory=$true)]
		[string]$Folder,
		[string]$SubString
	)
	
	foreach ($item in (Get-Item -Path "$Folder\\*" -Filter ("*"+$SubString+"*") | ?{$_.Attributes -like "Directory"})) 
	{ 
		$newname = (($item.basename -replace $SubString, "")).Trim();
		Rename-Item -Path ($item.fullname) -NewName $newname -WhatIf:$false
	}
}

#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString MP3-VBR
#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString MP3-CBR
#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString " 320Kbps"
#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString " 320Kpbs"
#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString " 128Kbps"
#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString " 256Kbps"
#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString " 160Kbps"
#Remove-SubString-From-FolderName -Folder K:\Music\Bollywood -SubString "OST"

#Get-item -path '.\*' -Include '* )*' | ?{$_.Attributes -like "Directory"} | Rename-item -newname {$_.name -replace ' \)',')'} -WhatIf:$false
#Get-item -path '.\*' -Include '*( *' | ?{$_.Attributes -like "Directory"} | Rename-item -newname {$_.name -replace "\( ","("} -WhatIf:$false
#Get-item -path '.\*' -Include '*  *' | ?{$_.Attributes -like "Directory"} | Rename-item -newname {$_.name -replace '  ',' '} -WhatIf:$false

#Get-item -path '.\*' -Include '*`[*' | ?{$_.Attributes -like "Directory"} | ft fullname
#Get-item -path '.\*' -Include '*`[*' | ?{$_.Attributes -like "Directory"} | Rename-item -newname {$_.name -replace "\[","("} -WhatIf:$false
#Get-item -path '.\*' -Include '*`]*' | ?{$_.Attributes -like "Directory"} | Rename-item -newname {$_.name -replace "\]",")"} -WhatIf:$false

# Find empty directories
#dir | ?{($_.attributes -like "Directory") -and ($_.getfiles().length -eq 0)} | ft fullname

#Modify alphabets in the front of folder names
#Trims the name at end to remove leading and trailing spaces
#Dir -Filter is effective with directories, not -include
function ModifyFolderName
{
	param(
		[string]$Folder=".",
		[string]$operation=""
	)
	
	#Non recursively remove the numeric characters from beginning
	if ($operation.CompareTo("NRRemoveLeadingNumerals") -eq 0)
	{
		"NonRecursiveRemovalOfLeadingNumerals"
		for ($i=0; $i -ile 9; $i += 1)
		{
			for ($j=0; $j -ile 9; $j += 1)
			{
				$SubString = $i.Tostring()+$j.Tostring();
				foreach ($item in (Get-Item -Path "$Folder\\*" -Filter ($SubString+" *") | ?{$_.Attributes -like "Directory"})) 
				{ 
					Rename-Item -Path ($item.fullname) -NewName ($item.basename.substring($SubString.length)).Trim() -WhatIf:$false
				}
			}
		}
	}
	
	#Non recursively Trim the name
	if ($operation.CompareTo("NRTrimName") -eq 0)
	{
		"Nonrecursivetrim"
		foreach ($item in (Get-Item -Path "$Folder\\*" | ?{$_.Attributes -like "Directory"})) 
		{ 
			if ($Item.BaseName.CompareTo($Item.BaseName.Trim()) -ne 0){
				Rename-Item -Path ($item.fullname) -NewName $Item.BaseName.Trim() -WhatIf:$false
			}
		}
	}
	
	#Change beginning lower case to upper case
	#http://www.techsupportalert.com/content/how-force-your-windows-file-and-folder-names-have-case-you-want.htm
	if ($operation.CompareTo("NRReplaceFirstCharToUpper") -eq 0)
	{	
		"NRReplaceFirstCharToUpper"
		foreach ($item in (Get-Item -Path "$Folder\\*" | ?{$_.Attributes -like "Directory"}))
		{
			$FirstChar = $Item.BaseName.SubString(0,1);
			if ($FirstChar.CompareTo($FirstChar.ToUpper()) -ne 0)
			{
				$ParentDir = $Item | split-path;
				Rename-Item -Path ($Item.fullname) `
					-NewName ("0" + $FirstChar.ToUpper() + $Item.BaseName.SubString(1)) `
					-WhatIf:$false
					
				Rename-Item -Path ($ParentDir + "\\0" + $item.BaseName)  `
					-NewName ($FirstChar.ToUpper() + $Item.BaseName.SubString(1)) `
					-WhatIf:$false
			}
		}
	}
}

#ModifyFolderName -Folder "Folder1" -Operation "NonRecursiveReplacementOfAlphabetsToUpperCase"
#ModifyFolderName "Folder1"

# Move folder after checking that parent folder exists
# Take data from an input file where rows are comma separated
# Current location, New location
function MoveFolderWithVerification
{
	param(
		[string]$InputFile,
		[string]$Operation=""
	)

    if ((Test-Path $InputFile) -eq $false)
    {
        Write-Host "Inputfile is missing"
        return
    }

    foreach ($Instruction in (Get-Content $InputFile))
    {
        $OldPath = ($Instruction -split ",")[0].Trim()
        $NewPath = ($Instruction -split ",")[1].Trim()

        if ((test-path $OldPath) -eq $false)
        {
            write-host ($OldPath + " does not exist")
            continue
        }
        if ($NewPath -match "\\")
        {
            write-host ($NewPath + " entry is wrongly formatted")
            continue
        }
        if ((test-path (Split-path $NewPath)) -eq $false) 
        {
            write-host ((Split-path $NewPath) + " does not exist")
            continue
        }

        Move-item -Path $OldPath -Destination (split-path $NewPath) -WhatIf:$true
    }
}

MoveFolderWithVerification -InputFile ".\FolderMove.txt"