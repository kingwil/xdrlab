$files = Get-ChildItem .\config*.ps1
foreach ($file in $files) {
   Publish-AzVMDscConfiguration -ConfigurationPath $file.FullName -OutputArchivePath ("..\DSC\" + $file.name + ".zip")
}