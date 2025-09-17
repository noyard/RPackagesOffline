function Get-RPackage {
    param (
        [string]$package
    )

    # Array of imports to ignore
    $ignoreImports = @("tools","stats", "utils", "graphics", "grDevices", "parallel","grid","methods")

    Write-Output "`n---$($package)"

    # Define the URL of the package index page
    $url = "https://cran.r-project.org/web/packages/$($package)/index.html"

    # Attempt to download the raw HTML content; handle missing pages gracefully
    try {
        $response = Invoke-WebRequest -Uri $url -ErrorAction Stop
    } catch {
        Write-Error "Package page not found: $url"
        return
    }
    $content = $response.Content

    # Use regex to find the href link after "r-release:"
    $pattern = 'r-release: <a href="([^"]+)"'
    if ($content -match $pattern) {
        $relativeUrl = $matches[1]
        if ($relativeUrl -match '../../../') {
            $fullUrl = $relativeUrl.Replace('../../../', 'https://cran.r-project.org/')
        } else {
            $fullUrl = $relativeUrl
        }

        Write-Output "r-release URL: $fullUrl"

        # Download the package to the current directory\packages folder
        $packageDir = Join-Path -Path $PWD -ChildPath "packages"
        if (-not (Test-Path -Path $packageDir)) {
            New-Item -Path $packageDir -ItemType Directory -Force | Out-Null
        }

        $uri      = [System.Uri]$fullUrl
        $fileName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
        if ([string]::IsNullOrEmpty($fileName)) {
            $fileName = "$package"
        }

        $packageFile = Join-Path -Path $packageDir -ChildPath $fileName
        if (-not (Test-Path -Path $packageFile)) {
            Write-Output "Downloading package to $packageFile"
            Invoke-WebRequest -Uri $fullUrl -OutFile $packageFile
        } else {
            Write-Output "Package already exists at $packageFile"
        }
    } else {
        Write-Error "r-release URL not found."
    }

    # Use regex to find the href links after "Imports:"
    $pattern = '<td[^>]*>\s*Imports:\s*</td>\s*<td[^>]*>(.*?)</td>'
    if ($content -match $pattern) {
        $importsRaw   = $matches[1]
        # Clean and split the package names
        $importsClean = ($importsRaw -replace '<[^>]+>', '') -split ',\s*'
        # Remove version constraints like " (>= 0.8)" or " (&amp;ge; 0.8)"
        $importsClean = $importsClean | ForEach-Object { ($_ -replace '\s*\(.*?\)', '') }

        foreach ($import in $importsClean) {
            #if not in ignore list
            if ($ignoreImports -notcontains $import) {
                Get-RPackage -package $import
            }
        }
        #$importsClean | ForEach-Object { Write-Output "$_"; Get-RPackage -package $_ }
    } else {
        #Write-Output "Imports section not found."
    }
}

