# Publish the LuckyDice control panel to GitHub Pages (public repo tonkla45110-cloud/luckydice-control).
# Run it yourself: right-click this file -> "Run with PowerShell". Running it again updates the page.
$ErrorActionPreference = "Stop"
$gh = "C:\Program Files\GitHub CLI\gh.exe"
$repo = "luckydice-control"
Set-Location $PSScriptRoot
Copy-Item "..\LuckyDice_Control.html" "index.html" -Force   # always publish the latest panel

$login = & $gh api user --jq .login
$id = & $gh api user --jq .id
Write-Host "GitHub account: $login"

if (-not (Test-Path ".git")) {
  git init -b main | Out-Null
  git config user.name $login
  git config user.email "$id+$login@users.noreply.github.com"   # GitHub noreply address, keeps your real e-mail private
}
& $gh auth setup-git
git add index.html
git commit -m "LuckyDice control panel update" 2>$null | Out-Null

$exists = $true
try { & $gh repo view "$login/$repo" --json name 2>$null | Out-Null; if ($LASTEXITCODE -ne 0) { $exists = $false } } catch { $exists = $false }
if (-not $exists) {
  & $gh repo create $repo --public --description "LuckyDice (ME320) control panel - Web Serial, Chrome/Edge" --source . --remote origin --push
  Start-Sleep 3
  & $gh api -X POST "repos/$login/$repo/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null
} else {
  if (-not (git remote)) { git remote add origin "https://github.com/$login/$repo.git" }
  git push -u origin main
}
$url = "https://$login.github.io/$repo/"
Write-Host ""
Write-Host "Done. The page goes live in 1-2 minutes:" -ForegroundColor Green
Write-Host $url -ForegroundColor Green
Read-Host "Press Enter to close"
