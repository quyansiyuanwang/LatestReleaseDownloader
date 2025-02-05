param (
    [string]$owner,
    [string]$repo,
    [string]$pat,
    [string]$proxy,
    [string[]]$ignoreFolders
)

if ($proxy -and -not $proxy.StartsWith("http://") -and -not $proxy.StartsWith("https://")) {
    $proxy = "http://$proxy"
}

if (-not $owner) {
    $owner = Read-Host "Please enter the owner"
}
if (-not $repo) {
    $repo = Read-Host "Please enter the repo"
}


function Enter-to-exit {
    # Enter to exit
    param ()
    Pause
    exit
}

function Test-Path-Exists {
    # Test if the repo exists
    param (
        [string]$path,
        [string]$message,
        [bool]$necessary = $true,
        [bool]$reverse = $false
    )
    $level = if ($necessary) { "ERR" } else { "WARN" }
    if (Test-Path "$path") {
        Writer -message "$message" -level $level
        $delete = Read-Host "Enter Your Choice (Y/N)"
        if ($reverse) {
            $yesSignal = if ($reverse) { "N" } else { "Y" }
        }
        if ($delete.ToUpper() -eq $yesSignal) {
            Remove-Item -Path "$path" -Force -Recurse
            Write-Info "Deleted $path"
        }
        else {
            Writer -message "Skip deleting $path" -level $level
            if ($necessary) {
                Enter-to-exit
            }
        }
    }
}

function Writer{
    param (
        [string]$message,
        [string]$level
    )
    if ($level -eq "ERR") {
        Write-Err -message $message
    }
    elseif ($level -eq "INFO") {
        Write-Info -message $message
    }
    elseif ($level -eq "WARN") {
        Write-Warn -message $message
    }
}

function Write-Err {
    # Write error
    param (
        [string]$message
    )
    Write-Host "[ERR] $message" -ForegroundColor Red
}

function Write-Info {
    # Write info
    param (
        [string]$message
    )
    Write-Host "[INFO] $message" -ForegroundColor Green
}

function Write-Warn {
    # Write warning
    param (
        [string]$message
    )
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Get-Lastest-Release {
    # Get latest release
    param ()
    Write-Info "Getting latest release from URL: https://api.github.com/repos/$owner/$repo/releases/latest"
    try {
        $uri = "https://api.github.com/repos/$owner/$repo/releases/latest"
        $headers = @{}
        if ($pat) {
            $headers.Authorization = "token $pat"
        }

        $invokeParams = @{
            Uri         = $uri
            Headers     = $headers
            ErrorAction = 'Stop'
        }

        if ($proxy) {
            $invokeParams.Proxy = $proxy
        }

        $release = Invoke-WebRequest @invokeParams | ConvertFrom-Json
    }
    catch {
        $err = $_ | ConvertFrom-Json
        Write-Err -message "Failed to get latest release"
        Write-Err -message $err.message
        return $null
    }
    return $release
}

function Invoke-Download-File {
    # Invoke to download a file
    param (
        [string]$url,
        [string]$output
    )
    Write-Info "Downloading $url to $output"
    try {
        $headers = @{}
        if ($pat) {
            $headers.Authorization = "token $pat"
        }

        $invokeParams = @{
            Uri     = $url
            OutFile = $output
            Headers = $headers
            ErrorAction = 'Stop'
        }

        if ($proxy) {
            $invokeParams.Proxy = $proxy
        }

        Invoke-WebRequest @invokeParams
    }
    catch {
        $message = $_.Exception.Message
        Write-Err -message "Failed to download $zip_url"
        Write-Err -message $message
        return $false
    }
    return $true
}

function Move-Zip-Content-to-Root {
    # Move zip content
    param ()
    $zip_content = Get-ChildItem -Path "$repo" -Directory | Where-Object { $_.Name -like "$owner-$repo-*" }
    $zip_content_name = $zip_content.Name
    $items_to_move = Get-ChildItem -Path "$repo\$zip_content_name\*"
    foreach ($item in $items_to_move) {
        $ignore = $false
        foreach ($pattern in $ignoreFolders) {
            if ($item.FullName -match $pattern) {
                $ignore = $true
                break
            }
        }
        if (-not $ignore) {
            if (Test-Path -Path "$repo\$($item.Name)") {
                Remove-Item -Path "$repo\$($item.Name)" -Force -Recurse
            }
            Move-Item -Path $item.FullName -Destination "$repo" -Force
        }
    }
    Remove-Item -Path "$repo\$zip_content_name" -Force -Recurse
}


# ------------------------------ pre-check --------------------------------

Write-Info "owner: $owner"
Write-Info "repo: $repo"
Write-Info "pat: $pat"
Write-Info "proxy url: $proxy"
Write-Info "ignoreFolders: $ignoreFolders"


# ------------------------------ Main --------------------------------

# Check if the folder exists
Test-Path-Exists -path "$repo" `
    -message "The folder $repo already exists, do you want to overwrite it?" `
    -necessary $false

# Get latest
$release = Get-Lastest-Release
if ($null -eq $release) {
    Enter-to-exit
}

# preDownload
$download = $true
if (
    Test-Path-Exists `
        -path "$repo.zip" `
        -message "$repo.zip already exists, do you want to overwrite it?" `
        -necessary $false
    ) {
    Write-Warn "$repo.zip already exists"
    $overwrite = Read-Host "Do you want to overwrite it? (Y/N)"
    if ($overwrite.ToUpper() -eq "Y") {
        Write-Info "Overwriting $repo.zip"
    }
    else {
        $download = $false
        Write-Info "Skip downloading $repo.zip"
        Enter-to-exit
    }
}
$zip_url = $release.zipball_url

# Download and Check if the zip file exists
if ($download) {
    $res = Invoke-Download-File -url $zip_url -output "$repo.zip"
    if ($res -eq $false -or -not (Test-Path "$repo.zip")) {
        Write-Err -message "Failed to download $repo.zip"
        Enter-to-exit
    }
}

# Extract
Write-Info "Extracting $repo.zip"
Expand-Archive -Path "$repo.zip" -DestinationPath "$repo" -Force

# Clean up
Write-Info "Cleaning up $repo.zip"
Remove-Item -Path "$repo.zip" -Force

# Move zip content
Write-Info "Moving zip content to root"
Move-Zip-Content-to-Root

# Done
Write-Info "Done"
Enter-to-exit