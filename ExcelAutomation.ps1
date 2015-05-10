$FName = "E:\Temp\Book1.xlsx"
$ShName = "Sheet1"
$ColRange = "B:D"
$MaxRow = 100

$Excel = New-Object -ComObject excel.application
$Excel.visible = $true
$WorkBook = $Excel.Workbooks.Open($FName)
foreach ($Temp in $Workbook.worksheets){
	if ($Temp.Name -eq $ShName){$WorkSheet = $Temp}
}

for ($col = ($ColRange.split(":"))[0]; $col -le ($ColRange.split(":"))[1]; $col){
	for ($row = 1; $row -le $MaxRow; $row++){
		$Item = $WorkSheet.cells.item($row, $col).text
		if ($Item -and $Item.Length) {" $row , $col, $Item"}
	}
}

## $WorkBook.SaveAs($FName.replace(".", "_modified."))
$Excel.quit()
trap {$Excel.quit()}

#http://www.vistax64.com/powershell/174132-excel-powershell-open-workbook-multiple-sheets.html
#http://techstarts.wordpress.com/2008/05/05/powershell-and-excel/
#http://www.eggheadcafe.com/software/aspnet/32327624/powershell-saveas-with-ex.aspx
