<#
  One-step builder: installs missing build tools, publishes Cafe POS and creates the Windows installer.
  Usage:   double-click build.bat    (or)    powershell -ExecutionPolicy Bypass -File .\build.ps1
  Output:  dist\CafePOS-Setup-1.0.0.exe   <- this single file is what you give to your customers
  Only the machine that BUILDS the installer needs these tools; customers need nothing.
#>
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Have($name) { return [bool](Get-Command $name -ErrorAction SilentlyContinue) }
function Refresh-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
              [System.Environment]::GetEnvironmentVariable("Path","User")
}

if (-not (Have dotnet)) {
  if (-not (Have winget)) { throw "Install the .NET 8 SDK from https://dotnet.microsoft.com/download/dotnet/8.0 and re-run." }
  Write-Host "==> Installing .NET 8 SDK..." -ForegroundColor Cyan
  winget install --id Microsoft.DotNet.SDK.8 -e --accept-package-agreements --accept-source-agreements
  Refresh-Path
}

function Find-Iscc {
  $c = @("${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe", "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
         "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe")
  $p = $c | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $p -and (Have ISCC.exe)) { $p = (Get-Command ISCC.exe).Source }
  return $p
}
$iscc = Find-Iscc
if (-not $iscc) {
  if (-not (Have winget)) { throw "Install Inno Setup 6 from https://jrsoftware.org/isdl.php and re-run." }
  Write-Host "==> Installing Inno Setup..." -ForegroundColor Cyan
  winget install --id JRSoftware.InnoSetup -e --accept-package-agreements --accept-source-agreements
  Refresh-Path
  $iscc = Find-Iscc
  if (-not $iscc) { throw "Inno Setup installed but ISCC.exe was not found. Open a new terminal and re-run." }
}

Write-Host "==> Publishing (self-contained, win-x64)..." -ForegroundColor Cyan
if (Test-Path publish) { Remove-Item publish -Recurse -Force }
dotnet publish src\CafePOS.csproj -c Release -r win-x64 --self-contained true -o publish
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed" }

Write-Host "==> Building installer..." -ForegroundColor Cyan
& $iscc installer\CafePOS.iss
if ($LASTEXITCODE -ne 0) { throw "Inno Setup failed" }

Write-Host ""
Write-Host "Done. Installer: $(Resolve-Path dist\CafePOS-Setup-*.exe)" -ForegroundColor Green
