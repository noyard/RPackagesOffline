# Path to R executable
$rPath = "${env:ProgramFiles}\R\R-3.1.0\bin\R.exe"

# Path to the packages folder
$packagesFolder = ".\packages"

# Get all .zip files in the folder
$packageZips = Get-ChildItem -Path $packagesFolder -Filter "*.zip"

# Loop through each zip and install
foreach ($zip in $packageZips) {
    $zipPath = $zip.FullName
    Write-Output "Installing $($zip.Name)..."
    Start-Process -FilePath $rPath -ArgumentList "CMD INSTALL `"$zipPath`"" -NoNewWindow -Wait
}
