$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$owner = 'DanielWhatsGood'
$repo  = 'MacKeys'
$url   = "https://github.com/$owner/$repo.git"

function Fail($msg) { Write-Host ""; Write-Host $msg -ForegroundColor Red; Read-Host "Press Enter to close"; exit 1 }

Write-Host "Publishing this folder to github.com/$owner/$repo"
Write-Host ""

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "Git is not installed.`n`nInstall it, then run this again:`n    winget install --id Git.Git -e"
}

# --- local repo ---
if (-not (Test-Path .git)) {
    Write-Host "Creating the local repository..."
    git init -b main | Out-Null
} else {
    Write-Host "Local repository already exists."
}

if (-not (git config user.email)) {
    git config user.email "daniel.changxu.wu@gmail.com"
    git config user.name  "Daniel Wu"
    Write-Host "Set a commit identity for this folder only."
}

git add -A
if (git status --porcelain) {
    $msg = Read-Host "Commit message (Enter for 'Update MacKeys')"
    if (-not $msg) { $msg = "Update MacKeys" }
    git commit -m $msg | Out-Null
    Write-Host "Committed."
} else {
    Write-Host "Nothing new to commit."
}

# --- remote repo ---
Write-Host ""
Write-Host "Checking whether the repo exists on GitHub..."
$exists = $false
try { git ls-remote $url 2>$null | Out-Null; if ($LASTEXITCODE -eq 0) { $exists = $true } } catch { }

if (-not $exists) {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "Creating it with the GitHub CLI..."
        gh repo create "$owner/$repo" --public --source=. --remote=origin --push
        if ($LASTEXITCODE -eq 0) { Write-Host ""; Write-Host "Done: https://github.com/$owner/$repo"; Read-Host "Press Enter to close"; exit 0 }
        Write-Host "The GitHub CLI could not do it. Falling back to the website." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Opening GitHub so you can create the empty repo."
    Write-Host "  - Name it exactly:  $repo"
    Write-Host "  - Public"
    Write-Host "  - Do NOT add a README, .gitignore or licence"
    Start-Process "https://github.com/new?name=$repo&visibility=public"
    Read-Host "Press Enter once you have clicked Create repository"
}

if (-not (git remote | Where-Object { $_ -eq 'origin' })) {
    git remote add origin $url
} else {
    git remote set-url origin $url
}

Write-Host ""
Write-Host "Pushing... a browser sign-in may pop up the first time."
git push -u origin main
if ($LASTEXITCODE -ne 0) { Fail "Push failed. If it mentioned authentication, sign in when prompted and run this again." }

Write-Host ""
Write-Host "Done: https://github.com/$owner/$repo" -ForegroundColor Green
Write-Host "The download button in the README points at the latest main."
Read-Host "Press Enter to close"
