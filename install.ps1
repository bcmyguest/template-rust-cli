# Installs the template-rust-cli release binary on Windows.
#
#   irm https://raw.githubusercontent.com/bcmyguest/template-rust-cli/main/install.ps1 | iex
#
# TEMPLATE_RUST_CLI_VERSION      release to install, such as 0.1.0 (default: latest)
# TEMPLATE_RUST_CLI_INSTALL_DIR  where the binary goes (default: %LOCALAPPDATA%\template-rust-cli\bin)
# TEMPLATE_RUST_CLI_RELEASE_URL  releases base URL (default: the GitHub releases page)
$ErrorActionPreference = 'Stop'

$version = if ($env:TEMPLATE_RUST_CLI_VERSION) { $env:TEMPLATE_RUST_CLI_VERSION } else { 'latest' }
$installDir = if ($env:TEMPLATE_RUST_CLI_INSTALL_DIR) { $env:TEMPLATE_RUST_CLI_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'template-rust-cli\bin' }
$base = if ($env:TEMPLATE_RUST_CLI_RELEASE_URL) { $env:TEMPLATE_RUST_CLI_RELEASE_URL } else { 'https://github.com/bcmyguest/template-rust-cli/releases' }

if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
    throw "template-rust-cli install: no release build for Windows $env:PROCESSOR_ARCHITECTURE"
}
$name = 'template-rust-cli-x86_64-pc-windows-msvc.tar.gz'
$url = if ($version -eq 'latest') { "$base/latest/download/$name" } else { "$base/download/v$($version.TrimStart('v'))/$name" }

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$tmp = Join-Path $installDir ".template-rust-cli-install.$([guid]::NewGuid())"
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $archive = Join-Path $tmp $name
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $archive
    Invoke-WebRequest -UseBasicParsing -Uri "$url.sha256" -OutFile "$archive.sha256"
    $expected = ((Get-Content "$archive.sha256" -Raw) -split '\s+')[0]
    $actual = (Get-FileHash -Algorithm SHA256 $archive).Hash.ToLower()
    if ($actual -ne $expected.ToLower()) { throw "template-rust-cli install: checksum mismatch for $name" }
    $out = Join-Path $tmp 'out'
    New-Item -ItemType Directory -Path $out | Out-Null
    tar.exe -xzf $archive -C $out
    if ($LASTEXITCODE -ne 0) { throw "template-rust-cli install: cannot extract $name" }
    Get-ChildItem $out | Move-Item -Force -Destination $installDir
} finally {
    Remove-Item -Recurse -Force $tmp
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (($userPath -split ';') -contains $installDir)) {
    [Environment]::SetEnvironmentVariable('Path', "$installDir;$userPath", 'User')
    Write-Host "Added $installDir to your user PATH; open a new terminal to use it."
}
Write-Host "template-rust-cli installed to $installDir"
