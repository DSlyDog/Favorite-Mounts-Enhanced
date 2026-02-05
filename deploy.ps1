# Set variables
$SourceDir = "E:\Games\World of Warcraft\_retail_\Interface\AddOns\Whisp's Mount Up - Dev"
$ReleaseDir = "E:\Games\World of Warcraft\_retail_\Interface\AddOns\Whisp's Mount Up"

# List of files/folders to exclude from release
$Excludes = @(
    ".git",
    ".idea",
    "REMOVE BEFORE PACKING",
    "deploy.ps1"
)

# Ensure the release directory is clean
if (Test-Path $ReleaseDir) {
    Remove-Item $ReleaseDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ReleaseDir | Out-Null

# Copy files, excluding unwanted folders/files
function Copy-AddonContent {
    param($src, $dst)
    Get-ChildItem $src -Force | ForEach-Object {
        if ($Excludes -contains $_.Name) {
            Write-Host "Skipping: $($_.FullName)"
        }
        else {
            $target = Join-Path $dst $_.Name
            if ($_.PSIsContainer) {
                New-Item -ItemType Directory -Path $target | Out-Null
                Copy-AddonContent $_.FullName $target
            }
            else {
                Copy-Item $_.FullName $target
            }
        }
    }
}

Copy-AddonContent $SourceDir $ReleaseDir
