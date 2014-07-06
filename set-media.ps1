##################################################################################
#
#  Script name: Set-Media.ps1
#  Author:      goude@powershell.nu
#  Homepage:    www.powershell.nu
#
#  Requirements: http://developer.novell.com/wiki/index.php/TagLib_Sharp
#
##################################################################################

param([string]$Folder, [string]$LogFile = ("C:\Logs\ErrLog.txt"), [switch]$help)

# Change Variable TagLib so that it points to the taglib-sharp.dll file.

$TagLib = "F:\Experiments\taglib-sharp-2.0.3.3-windows\Libraries\taglib-sharp.dll"

[System.Reflection.Assembly]::LoadFile($TagLib) | Out-Null

function GetHelp() {

$HelpText = @"

DESCRIPTION:

NAME: Set-Media.ps1

This Script uses the TagLib Sharp Class in order to Set Metadata on Media Files
such As: mp3, aa3, aac, wma and m4a.
The Script presumes that the folder including the media files is named: "Artist - Album"

PARAMETERS: 

-Folder          Name of the Top Level Folder Containing Media Files (required)
-help            Prints the HelpFile (Optional)

SYNTAX:

Set-Media.ps1 -Folder C:\MyMusic\Rock -LogFile C:\Log\SetMediaLog.txt

Runs through all Child Folders in C:\MyMusic\Rock\
and sets the Metadata tags on the media files in the folder.

SCRIPTNAME.ps1 -help

Displays the helptext

EXAMPLES:

The Directory C:\MyMusic\Rock contains the following Subfolders:

Artist1 - Album1
	01 - Track One.mp3
	02 - Track Two.mp3
	03 - Track Three.mp3
Artist2
	01 - Track One.mp3
	02 - Track Two.mp3
	03 - Track Three.mp3
Artist3 - Album3 - Great Album
	01 - Track One.mp3
	02 - Track Two.mp3
	03 - Track Three.mp3

Each SubFolder contains Media files. If we run the script on the top level Folder:

Set-Media.ps1 -Folder C:\MyMusic\Rock

Files in "Artist1 - Album1" will get their Artist to equal Artist1 and their Album will be set to Album1.
Files in "Artist2" Won't get any information written since the album lacks information regarding Album Name.
Files in "Artist3 - Album3 - Great Album" will get their Artist set to Artist3 and their Album will be set to Album3 Great Album
The Genre will be set to Rock

"@
$HelpText
}

function Set-MusicProperties([string]$Folder, [string]$LogFile) {

	$Genre = Split-Path $Folder -leaf

	# Get Folders

	$ChildFolders = Get-ChildItem $Folder | Where { $_.PsIsContainer }

	$ChildFolders | ForEach {

		$CurrentFolder = $_

		"Processing: $($CurrentFolder.FullName)"

		$FolderName = Split-Path $CurrentFolder.FullName -leaf

		$ArtistAndAlbum = $FolderName.Split("-")

		$Artist = $ArtistAndAlbum[0]

		if($ArtistAndAlbum.Count -eq 2) {
			$Album = $ArtistAndAlbum[1]
		} else {
			for($i = 1; $i -lt $ArtistAndAlbum.Count; $i ++) {
				[string]$Album += ($ArtistAndAlbum[$i].TrimStart()).TrimEnd() + " "
			}
		}

		$Artist = $Artist.TrimStart()
		$Artist = $Artist.TrimEnd()
		$Artist = $Artist -Replace "_"," "
		$Artist = $Artist -Replace "[()\[\]]",""

		$Album = $Album.TrimStart()
		$Album = $Album.TrimEnd()
		$Album = $Album -Replace "_"," "
		$Album = $Album -Replace "[()\[\]]",""

		if($Album.Length -eq 0 -or $Album -eq $Null) {

			 "Missing Metadata Information regarding Album: " + $CurrentFolder.FullName | Add-Content $LogFile

		} elseif($Artist.Length -eq 0 -or $Artist -eq $Null) {

			"Missing Metadata Information regarding Artist: " + $CurrentFolder.FullName | Add-Content $LogFile

		} elseif($Genre.Length -eq 0 -or $Genre -eq $Null) {

			"Missing Metadata Information regarding Genre: " + $CurrentFolder.FullName | Add-Content $LogFile

		} else {

			$Items = Get-ChildItem -path $CurrentFolder.FullName -rec -include *.mp3,*.aa3,*.aac,*.wma,*.m4a

			$Items | ForEach {

				try {
					$Media  =  [TagLib.File]::Create($_.FullName)
				}
				catch {
					$Err = $True
				}

				if ($Err -eq $True) {
					"Unable to Load File through [TagLib.File]: " + $CurrentFolder.FullName | Add-Content $LogFile
				} else {

					$Title = (Split-Path $_.FullName -Leaf) -Replace ".* - ",""
					$Title = $Title -Replace ".mp3",""
					$SongNumber = (Split-Path $_.FullName -Leaf) -Replace " - .*",""

					$Media.Tag.Performers = $Artist
					$Media.Tag.AlbumArtists = $Artist
					$Media.Tag.Artists = $Artist
					$Media.Tag.Album = $Album
					$Media.Tag.Genres = $Genre
					$Media.Tag.Track = $SongNumber
					$Media.Tag.Title = $Title
					

					$Media.Save()
				}
			}
			$Artist = $Null
			$Album = $Null
			$Media =  $Null
			$Err = $False
		}
	}
}

if($help) { GetHelp; Continue }
if($Folder) { Set-MusicProperties -Folder $Folder -LogFile $LogFile }