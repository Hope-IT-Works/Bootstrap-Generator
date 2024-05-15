<#

.NAME
    Bootstrap Generator
.SYNOPSIS
    Initializes a bootstrap project
.DESCRIPTION
    Initializes a bootstrap project. Can also include Bootstrap Icons.
.EXAMPLE
    ./bootstrap-generator.ps1
.PARAMETER WithBootstrapIcons
    Add parameter to include Bootstrap Icons
.PARAMETER WithTemplate
    Add parameter to include a index.html template
.PARAMETER DirectoryName
    Name for the assets directory
.PARAMETER DestinationPath
    Directory path where the files will be saved

#>

Param
(
[Parameter(HelpMessage="Add parameter to include Bootstrap Icons")]
    [switch]
    $WithBootstrapIcons,
[Parameter(HelpMessage="Add parameter to include a index.html template")]
    [switch]
    $WithTemplate,
[Parameter(HelpMessage="Name for the assets directory")]
    [string]
    $DirectoryName = "assets",
[Parameter(HelpMessage="Directory path where the files will be saved")]
    [string]
    $DestinationPath = (Get-Location).Path
)

function Get-BG_BooleanUserInput($Prompt){
    if($Prompt.Length -gt 0){
        $Prompt = $Prompt + " "
    }
    do {
        $Result = Read-Host -Prompt ($Prompt + "(y|j/n)")
    } while ($Result -notin "y","j","n")
    if($Result -eq "n"){
        $Result = $false
    } else {
        $Result = $true
    }
    return $Result
}

function Invoke-BG_Error($Message){
    Write-Error $Message
    exit 1
}

Write-Host "Welcome to the Bootstrap Generator"

# Verify the destination path
Write-Host "Please check if the following path is correct:"
Write-Host ('"'+$DestinationPath+'"')
if(!(Get-BG_BooleanUserInput -Prompt "Is this the correct path?")){
    Invoke-BG_Error -Message "Script aborted by user"
}

# Create the directory, if it does not exist
$BG_DownloadPath = Join-Path -Path $DestinationPath -ChildPath $DirectoryName
if(Test-Path -Path $BG_DownloadPath){
    Write-Host ('The directory "'+$BG_DownloadPath+'" already exists.')
    if(!(Get-BG_BooleanUserInput -Prompt "Do you want to proceed?")){
        Invoke-BG_Error -Message "Script aborted by user"
    }
    Remove-Item -Path $BG_DownloadPath -Recurse -Force
}
Write-Host ('Creating the directory "'+$BG_DownloadPath+'"')
New-Item -Path $BG_DownloadPath -ItemType Directory | Out-Null

# Get the latest Bootstrap release
try {
    Write-Host "Getting the latest Bootstrap release"
    $Bootstrap_Release = Invoke-RestMethod -Uri "https://api.github.com/repos/twbs/bootstrap/releases/latest"
} catch {
    Invoke-BG_Error -Message "Failed to get the latest Bootstrap release"
}
$Bootstrap_Assets = $Bootstrap_Release.assets | Where-Object { $_.name -like "*dist*" -and $_.content_type -eq "application/x-zip-compressed" -and $_.name -notlike "*example*" } | Select-Object -First 1

Write-Host "Found the latest Bootstrap release: $($Bootstrap_Release.tag_name)"
Write-Host "Found the Bootstrap assets: $($Bootstrap_Assets.name)"

# Download the Bootstrap assets
$Bootstrap_FilePath = Join-Path -Path $BG_DownloadPath -ChildPath $Bootstrap_Assets.name
try {
    Write-Host "Downloading the Bootstrap assets"
    Invoke-WebRequest -Uri $Bootstrap_Assets.browser_download_url -OutFile $Bootstrap_FilePath
} catch {
    Invoke-BG_Error -Message "Failed to download the Bootstrap assets"
}

# Extract the Bootstrap assets
$Bootstrap_DestinationPath = Join-Path -Path $BG_DownloadPath -ChildPath "bootstrap"
try {
    Write-Host "Extracting the Bootstrap assets"
    Expand-Archive -Path $Bootstrap_FilePath -DestinationPath $Bootstrap_DestinationPath
} catch {
    Invoke-BG_Error -Message "Failed to extract the Bootstrap assets"
}

# Remove the Bootstrap assets zip file
Write-Host "Removing the Bootstrap assets zip file"
Remove-Item -Path $Bootstrap_FilePath -Force

# Move the Bootstrap assets
Write-Host "Moving the Bootstrap assets"
Get-ChildItem -Path $Bootstrap_DestinationPath -Directory -Recurse | ForEach-Object {
    if($_.Name -eq "css" -or $_.Name -eq "js"){
        Move-Item -Path $_.FullName -Destination $BG_DownloadPath -Force
    }
}

# Remove the Bootstrap assets directory
Write-Host "Removing temporary Bootstrap assets directory"
Remove-Item -Path $Bootstrap_DestinationPath -Recurse -Force

Write-Host "Bootstrap assets are now ready!"

if($WithBootstrapIcons){
    # Get the latest Bootstrap Icons release
    try {
        Write-Host "Getting the latest Bootstrap Icons release"
        $Bootstrap_Icons_Release = Invoke-RestMethod -Uri "https://api.github.com/repos/twbs/icons/releases/latest"
    } catch {
        Invoke-BG_Error -Message "Failed to get the latest Bootstrap Icons release"
    }
    $Bootstrap_Icons_Assets = $Bootstrap_Icons_Release.assets | Where-Object { $_.content_type -eq "application/x-zip-compressed" -and $_.name -notlike "*example*" } | Select-Object -First 1
    Write-Host "Found the latest Bootstrap Icons release: $($Bootstrap_Icons_Release.tag_name)"
    Write-Host "Found the Bootstrap Icons assets: $($Bootstrap_Icons_Assets.name)"

    # Download the Bootstrap Icons assets
    $Bootstrap_Icons_FilePath = Join-Path -Path $BG_DownloadPath -ChildPath $Bootstrap_Icons_Assets.name
    try {
        Write-Host "Downloading the Bootstrap Icons assets"
        Invoke-WebRequest -Uri $Bootstrap_Icons_Assets.browser_download_url -OutFile $Bootstrap_Icons_FilePath
    } catch {
        Invoke-BG_Error -Message "Failed to download the Bootstrap Icons assets"
    }

    # Extract the Bootstrap Icons assets
    $Bootstrap_Icons_DestinationPath = Join-Path -Path $BG_DownloadPath -ChildPath "bootstrap-icons"
    try {
        Write-Host "Extracting the Bootstrap Icons assets"
        Expand-Archive -Path $Bootstrap_Icons_FilePath -DestinationPath $Bootstrap_Icons_DestinationPath
    } catch {
        Invoke-BG_Error -Message "Failed to extract the Bootstrap Icons assets"
    }

    # Remove the Bootstrap Icons assets zip file
    Write-Host "Removing the Bootstrap Icons assets zip file"
    Remove-Item -Path $Bootstrap_Icons_FilePath -Force

    # Move the Bootstrap Icons assets
    Write-Host "Moving the Bootstrap Icons assets"
    Get-ChildItem -Path $Bootstrap_Icons_DestinationPath -Directory -Recurse | ForEach-Object {
        if($_.Name -eq "font"){
            Move-Item -Path $_.FullName -Destination $BG_DownloadPath -Force
        }
    }

    # Remove the Bootstrap Icons assets directory
    Write-Host "Removing temporary Bootstrap Icons assets directory"
    Remove-Item -Path $Bootstrap_Icons_DestinationPath -Recurse -Force

    Write-Host "Bootstrap Icons assets are now ready!"
}

if($WithTemplate){
    if($WithBootstrapIcons){
        Write-Host "Downloading the index_with-icons.html template to index.html"
        Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hope-IT-Works/Bootstrap-Generator/main/index_with-icons.html" -OutFile (Join-Path -Path $BG_DownloadPath -ChildPath "index.html")
    } else {
        Write-Host "Downloading the index.html template to index.html"
        Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hope-IT-Works/Bootstrap-Generator/main/index.html" -OutFile (Join-Path -Path $BG_DownloadPath -ChildPath "index.html")
    }
    Write-Host "The index.html template has been downloaded!"
} else {
    Write-Host "Skipping the index.html template download as the parameter -WithTemplate was not used"
}

Write-Host ""
Write-Host "Bootstrap project initialization completed!"
Write-Host "Bootstrap Version: $($Bootstrap_Release.tag_name)"
if($WithBootstrapIcons){
    Write-Host "Bootstrap Icons Version: $($Bootstrap_Icons_Release.tag_name)"
}
